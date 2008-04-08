From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: RE: A Linux TCP SACK Question
Date: Tue, 8 Apr 2008 09:36:44 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804080007020.20936@wrl-59.cs.helsinki.fi>
References: <fc471cb97cfd.47f5520e@fnal.gov>
 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
 <000001c8967c$496efa20$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804042253000.415@wrl-59.cs.helsinki.fi>
 <000b01c89699$00e99590$c95ee183@D2GT6T71> <Pine.LNX.4.64.0804050031400.8186@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0804050037380.8186@wrl-59.cs.helsinki.fi>
 <000f01c896a1$3022fec0$c95ee183@D2GT6T71> <649aecc70804051417l4cf9b30asec8ca8d55e79e051@mail.gmail.com>
 <fb8e9e4f102e.47f8ebfd@fnal.gov> <649aecc70804061543v3ca3d0dau2ce303ecd2310bdc@mail.gmail.com>
 <000701c898bf$99fc3f80$c95ee183@D2GT6T71>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Sangtae Ha' <sangtae.ha@gmail.com>,
	'John Heffner' <johnwheffner@gmail.com>,
	'Netdev' <netdev@vger.kernel.org>
To: Wenji Wu <wenji@fnal.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50801 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbYDHGgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 02:36:48 -0400
In-Reply-To: <000701c898bf$99fc3f80$c95ee183@D2GT6T71>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Apr 2008, Wenji Wu wrote:

> >I don't think reorderings frequently happened in your directly
> >connected networking scenario. Please post your tcpdump file for
> >clearing out all doubts.
> 
> https://plone3.fnal.gov/P0/WAN/Members/wenji/tcp_dump_files_sack/
> 
> Two tcpdump files: one with SACK on, the other with SACK off. The test
> configures described in my previous emails.

NewReno never retransmitted anything in them (except at the very end of 
the transfer). Probably something related to how tp->reordering behaves
I suppose...

ijjarvin@pointhope:~/linux/debug$ /usr/sbin/tcpdump -n -r nosack | grep 
"4888[35] >" | cut -d ' ' -f 7- | cut -d ':' -f 1 | awk '{if ($1 < old) 
{print $1}; old=$1;}'
reading from file nosack, link-type EN10MB (Ethernet)
1
641080641
ijjarvin@pointhope:~/linux/debug$ 

ijjarvin@pointhope:~/linux/debug$ /usr/sbin/tcpdump -n -r sack | grep 
"4888[35] >" | cut -d ' ' -f 7- | cut -d ':' -f 1 | awk '{if ($1 < old) 
{print $1}; old=$1;}'
reading from file sack, link-type EN10MB (Ethernet)
1
7265
10161
141929
175233
196953
446558881
3542223511
ijjarvin@pointhope:~/linux/debug$ 


This is probably far fetched but could you tell us how you make sure that 
earlier connection's metrics are not affecting the latter connection? 
Ie., the discovered reordering is not transferred across the flows (in CBI 
like manner) and thus newreno has unfair advantage?

-- 
 i.
