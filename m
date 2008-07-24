From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Traffic control cgroups subsystem
Date: Thu, 24 Jul 2008 02:17:53 +0200
Message-ID: <4887CA31.7070308@trash.net>
References: <Pine.LNX.4.64.0807221041210.1091@ranjit.corp.google.com>	 <20080723150536.ded38b22.akpm@linux-foundation.org>	 <4887B1F0.3000407@trash.net> <166fe7950807231654ib5759e1kae54887f0918d3fb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lizf@cn.fujitsu.com, menage@google.com
To: Ranjit Manomohan <ranjitm@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50134 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755546AbYGXASE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 20:18:04 -0400
In-Reply-To: <166fe7950807231654ib5759e1kae54887f0918d3fb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ranjit Manomohan wrote:
> On Wed, Jul 23, 2008 at 3:34 PM, Patrick McHardy <kaber@trash.net> wrote:
>>
>> It is by the flow_change() function, but special casing the
>> CGROUP_CLASSID is not acceptable anyway. There should be no
>> need for that, a simple linear mapping to classids is done
>> by default in mapping mode, the sk_cgroup_classid simply
>> shouldn't include qdisc IDs.
> 
> I did not want to special case it but I want an identity mapping not a
> linear one.  For some reason a baseclass of X:0 is not allowed

An ID of X:0 identifies a qdisc, not a class, which is why this
isn't accepted.

> and
> there does not seem to be a clean way to get a 1-1 mapping (tc.classid
> -> X:tc.classid). I would have to workaround it by using a baseclass
> of the form X:Y and then subtracting Y from the value written to
> tc.classid which seemed very non intuitive.
> 
> Any particular reason for this restriction? Am I missing any other
> technique of getting a 1-1 mapping using the flow classifier?

My suggestion to replace your classifier by cls_flow was wrong, sorry.

You can't do classification that don't use linear mappings or hash
distribution, but we really should support that. We should keep your
classifier (with the change to use skb->sk), but please extend it by
the standard classifier features like ematches, actions and policers
(see flow_classify() for a simple example). Adding the cgroup to
cls_flow still makes sense, but as regular key without the baseclass
modification.
