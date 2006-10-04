From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH v4 1/2] NetLabel: secid reconciliation support
Date: Wed, 4 Oct 2006 15:02:56 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CF939@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, eparis@redhat.com,
	jmorris@namei.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:4788 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1750815AbWJDTD0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 15:03:26 -0400
To: Paul Moore <paul.moore@hp.com>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>  * XFRM present
> 
>    xfrm_sid = <full context from xfrm>
>    loc_sid = SECINITSID_NETMSG
>    nlbl_sid = SECSID_NULL/0
>    ext_sid = xfrm_sid
>    final skb->secmark = avc_ok : ext_sid ? unchanged
> 
>  * NetLabel present
> 
>    xfrm_sid = SECSID_NULL/0
>    loc_sid = SECSID_NULL/0
>    nlbl_sid = <SECINITSID_NETMSG te ctx, netlabel mls ctx>
>    ext_sid = nlbl_sid
>    final skb->secmark = avc_ok : ext_sid ? unchanged

I was referring to the differences in what getpeercon would
return in the above 2 scenarios.

In the xfrm case:     final skb->secmark would be 0 resulting in getpeercon
to return EPROTONOOPT
In the NetLabel case: final skb->secmark would be network_t resulting in
getpeercon to return network_t

> 
>  * Nothing
> 
>    xfrm_sid = SECSID_NULL/0
>    loc_sid = SECSID_NULL/0
>    nlbl_sid = SECSID_NULL/0
>    ext_sid = xfrm_sid
>    final skb->secmark = avc_ok : ext_sid ? unchanged
> 
> > This has implications for getpeercon() where it would
> > 
> > - fail with ENOPROTOOPT (xfrm case)
> > - returns network_t (netlabel)
> > 
> > I would still argue that the nature of the domain being carried by
> > the packet is still unlabeled_t as implied by the null 
> secmark. While
> > I view secmark/point as specifying BOTH a flow control point and a
> > default domain (incidentally using the same label more because of
> > implementation constrainst), I view network_t as purely a 
> flow control
> > point.
> > 
> > But I also realize there can be equally forceful arguments 
> for what this
> > patch does.
> 
> I know the two of us have talked about this before on the mail lists,
> but I don't believe anyone else has ever made a comment in 
> this regard.
>  I tend to feel rather strongly that when using just NetLabel on a
> connection you shouldn't see an "unlabeled_t" type as I feel that the
> connotation associated with this type is misleading, even 
> though from a
> TE point of view there may be an argument made that it is appropriate.
> 
> > What does the community think? We need to resolve it one way or the
> > other unless the above differences in behavior are desired 
> or somehow
> > accounted for in policy and apps.
> 
> I agree - I'd like to hear what others (namely Stephen Smalley, James
> Morris and all of the Tresys folks <past and present>) have to say on
> this issue.
> 
> -- 
> paul moore
> linux security @ hp
> 
