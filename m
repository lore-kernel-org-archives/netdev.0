From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH 6/8] scm: Capture the full credentials of the scm
 sender.
Date: Tue, 15 Jun 2010 23:47:19 -0500
Message-ID: <20100616044719.GA23863@hallyn.com>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org>
 <m1d3vvgirx.fsf@fess.ebiederm.org>
 <20100615214541.GA22570@hallyn.com>
 <m1sk4oueym.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Containers <containers@lists.osdl.org>,
	Serge Hallyn <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@parallels.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.125]:37004 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873Ab0FPErE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 00:47:04 -0400
Content-Disposition: inline
In-Reply-To: <m1sk4oueym.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Eric W. Biederman (ebiederm@xmission.com):
> "Serge E. Hallyn" <serge@hallyn.com> writes:
> > I think this hunk needs to be documented.  I.e. given that scm_send()
> > will call scm_set_cred() before calling __scm_send, I don't see how
> > these conditions could happen?  If the condition can legitimately
> > happen, then given all of the pid_t vs struct pid and 'cred' vs. 'creds'
> > in these two hunks, I think a comment over each would be nice.
> 
> I think if you have the full context of __scm_send it becomes pretty obvious.
> 
> 		case SCM_CREDENTIALS:
> 			if (cmsg->cmsg_len != CMSG_LEN(sizeof(struct ucred)))
> 				goto error;
> 			memcpy(&p->creds, CMSG_DATA(cmsg), sizeof(struct ucred));
> 			err = scm_check_creds(&p->creds);
> 			if (err)
> 				goto error;
> 
> At this point we have just copied ucred from userspace.  We have done
> scm_check_creds to ensure we allow the user to send the pid, uid, and
> gid they have passed in.
> 
> These tests catch the case where the user is legitimately sending
> something other than their own credentials.

Of course.  Sorry.  And I even had the context in the window next to the
email...  So finally,

Acked-by: Serge E. Hallyn <serge@hallyn.com>

to the set, and I'm looking forward to this being in.  And it should solve
the nuisance of containers without private netns rebooting their hosts
when both use upstart.

thanks,
-serge
