From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6 extension header privileges
Date: Sun, 22 May 2016 03:08:10 +0200
Message-ID: <82086299-ddb2-8acc-1286-5a1a7b2bf311@stressinduktion.org>
References: <CALx6S36x2+HBLSYVBi0+rQAgejbVvvFF7fr0P13cTspxpJQCLg@mail.gmail.com>
 <1e22f140-920e-0d1c-4a43-03780fb380a8@stressinduktion.org>
 <20160521015604.GD2452@oracle.com>
 <1463823275.2335717.614453105.5011B2EE@webmail.messagingengine.com>
 <CALx6S36V8Bv1R+rKWB7u=Y8371aT7JybDdkEErrRtw_bsHrMaA@mail.gmail.com>
 <6a889c73-efb1-7d4c-ba33-8b076378fcb7@stressinduktion.org>
 <CALx6S36scChuaS+uygAu4zk9gEz_qA=BSwX4f=kC_YXurTpMqw@mail.gmail.com>
 <f007389f-4ed1-2b67-69b5-28cd999264b9@stressinduktion.org>
 <20160521174438.GA27990@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:52021 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751886AbcEVBIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2016 21:08:15 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id ED88920313
	for <netdev@vger.kernel.org>; Sat, 21 May 2016 21:08:13 -0400 (EDT)
In-Reply-To: <20160521174438.GA27990@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21.05.2016 19:46, Sowmini Varadhan wrote:
> Tom Herbert wrote:
>>>>> If you don't mind I'll change this to make specific options are
>>>>> privileged and not all hbh and destopt. There is talk in IETF about
>>>>> reinventing IP extensibility within UDP since the kernel APIs don't
>>>>> allow setting EH. I would like to avoid that :-)
> 
> Do you mean this
>   http://www.ietf.org/mail-archive/web/spud/current/msg00365.html
> 
> Maybe I misunderstood that rather long thread, but the author of that
> draft seems to be arguing for reinventing tcp congavoid and windowing 
> on top of udp to bypass kernel? ;-)

Hmm, haven't read carefully but isn't that just plain TCP in UDP? I saw
extension headers mentioned but haven't grasped why they deem necessary.

> Hannes Frederic Sowa wrote:
>>>> A white list of certain registered IPv6 IANA-options for non-priv whould
> 
> Problem is that APIs are not IANA'ed. 
> Even RFC 3542 is just Informationaal. 
> 
> And even the classic socket API's that come down from BSD are not 
> ietf'ed or iana'ed.

I think I don't completely understand this. IANA is numbering registry
and if we have the proper option number allocated we can make sensible
decisions and put options on the white list or provide a more complete
sensible implementation of the specification in the kernel.

E.g. if an option for encapsulation is going to be specified, normal
users should not be able to set those, like with CALIPSO or some VNI
inside hop-by-hop options. That should probably be controlled by a
routing table or a flow matching subsystem, in the kernel.

Congestion and windowing information need to be settable and receivable
from user space.

Unassigned option, we don't know anything about them so far and should
probably being blocked for the time being, as we don't know which spec
would use the number.

I think it is also in favor of the IETF to get those numbers specified
and allocated in a proper way, otherwise security won't be manageable at
all any more.

> Hannes Frederic Sowa wrote:
>> Can you give some more details about the planned new options? I think we
>> can also open the API up for all options where the fourth bit is set,
>> which AFAIK denotes the experimental option space. And only have a
>> blacklist for the fourth bit == 0 case. Otherwise this is something IETF
>> people probably know more about what an impact this change could have.
> 
> I think it would be ok for some options to be privileged, others to not.
> We certainly have precedent for that from the classic socket APIs..
> and man pages etc can document any restrictions, as we do with other
> ioctls/sockopts etc.

Sure, we can make options unprivileged, we just need to know which one
and find out the details how they mix with each other. Also user space
should only be allowed to query the options it is allowed to set, too,
and not the whole option blocks.

Bye,
Hannes
