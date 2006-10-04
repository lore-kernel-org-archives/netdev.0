From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH v4 1/2] NetLabel: secid reconciliation support
Date: Wed, 4 Oct 2006 15:53:07 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CF96F@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov, eparis@redhat.com,
	jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:38583 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1750919AbWJDTxh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 15:53:37 -0400
To: Stephen Smalley <sds@tycho.nsa.gov>, Paul Moore <paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Wed, 2006-10-04 at 15:27 -0400, Paul Moore wrote:
> > Venkat Yekkirala wrote:
> > >> * XFRM present
> > >>
> > >>   xfrm_sid = <full context from xfrm>
> > >>   loc_sid = SECINITSID_NETMSG
> > >>   nlbl_sid = SECSID_NULL/0
> > >>   ext_sid = xfrm_sid
> > >>   final skb->secmark = avc_ok : ext_sid ? unchanged

As noted subsequently, I actually meant to refer to the below
instead of the XFRM case above:

 * Nothing

   xfrm_sid = SECSID_NULL/0
   loc_sid = SECSID_NULL/0
   nlbl_sid = SECSID_NULL/0
   ext_sid = xfrm_sid
   final skb->secmark = avc_ok : ext_sid ? unchanged

> > >>
> > >> * NetLabel present
> > >>
> > >>   xfrm_sid = SECSID_NULL/0
> > >>   loc_sid = SECSID_NULL/0
> > >>   nlbl_sid = <SECINITSID_NETMSG te ctx, netlabel mls ctx>
> > >>   ext_sid = nlbl_sid
> > >>   final skb->secmark = avc_ok : ext_sid ? unchanged
> > > 
> > > I was referring to the differences in what getpeercon would
> > > return in the above 2 scenarios.
> > > 
> > > In the xfrm case:     final skb->secmark would be 0 
> resulting in getpeercon
> > > to return EPROTONOOPT
> > 
> > In the "XFRM present" case above if the access is allowed (avc_ok is
> > true) then the final skb->secmark value is going to be set 
> to the value
> > of ext_sid which is the xfrm_sid.  Any calls made to 
> getpeercon() would
> > return success with the context matching xfrm_sid.
> > 
> > I have a hunch we are still on different pages here ...
> > 
> > > In the NetLabel case: final skb->secmark would be 
> network_t resulting in
> > > getpeercon to return network_t
> > 
> > Yep, and I understand you would like to see it as 
> unlabeled_t.  I think
> > we both have valid arguments for either case and we are 
> just waiting to
> > hear from others.
> 
> I don't understand the argument for network_t, and it seems to violate
> our goals of 1) having consistent policy regardless of 
> network labeling
> mechanism, and 2) having getpeercon() always return a subject 
> label that
> can be used as a basis for avc_has_perm() and setexeccon() calls.

But in the case where there's no domain info, but a cipso label,
getpeercon will fail (EPROTONOOPT). Do I rememember that Paul was
trying to use a special SID to use as a base sid in this case?
