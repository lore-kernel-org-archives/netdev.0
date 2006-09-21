From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 1/6] NetLabel: correct improper handling of non-NetLabel
 peer contexts
Date: Thu, 21 Sep 2006 14:28:42 -0400
Message-ID: <4512D9DA.4030608@hp.com>
References: <20060921165703.251871000@hp.com> <20060921170335.013411000@hp.com> <Pine.LNX.4.64.0609211406030.7534@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org, sds@epoch.ncsc.mil,
	jmorris@redhat.com, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:56291 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1751307AbWIUS2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 14:28:44 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0609211406030.7534@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Thu, 21 Sep 2006, paul.moore@hp.com wrote:
> 
> 
>>Fix a problem where NetLabel would always set the value of 
>>sk_security_struct->peer_sid in selinux_netlbl_sock_graft() to the context of
>>the socket, causing problems when users would query the context of the
>>connection.  This patch fixes this so that the value in
>>sk_security_struct->peer_sid is only set when the connection is NetLabel based,
>>otherwise the value is untouched.
> 
> I'll let Thomas comment on the Netlink changes, as he's been working with 
> you on them.

Hey, third times the charm right?

 ;)

> These changes otherwise seem ok.  How much testing has this had with and 
> without Netlabel enabled?

Joshua Brindle started a thread on the SELinux list which uncovered at
least two problems that I am aware of, one with NetLabel overriding the
peer's context and one with IPsec labeling returning the context from
the wrong SA (I may have the details of this wrong, Venkat posted about
this in the same thread).  This patch correct the NetLabel problem and
was tested using the simple reproducer provided by Joshua; I tested both
on a NetLabel'd and non-NetLabel'd connection and the results were
correct.  I have also tested this patch with the getpeercon() enabled
version of xinetd in FC/Rawhide; when configured to use labeled
connections and used with NetLabel the daemon is spawned with the
correct MLS label, when configured to use labeled connections and
NetLabel is not used xinetd reports an error because getpeercon()
returns an error (desired behavior as there is no network label present
for the connection).

If there is some other test you would like to see run let me know and
I'll give it a shot and report the results.

-- 
paul moore
linux security @ hp
