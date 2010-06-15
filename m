From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 6/8] scm: Capture the full credentials of the scm sender.
Date: Tue, 15 Jun 2010 02:53:57 -0700
Message-ID: <m1r5k8bozu.fsf@fess.ebiederm.org>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org>
	<m1d3vvgirx.fsf@fess.ebiederm.org> <4C173510.4030007@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Serge Hallyn <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <daniel.lezcano@free.fr>, netdev@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:41562 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635Ab0FOJyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 05:54:07 -0400
In-Reply-To: <4C173510.4030007@openvz.org> (Pavel Emelyanov's message of "Tue\, 15 Jun 2010 12\:08\:48 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov <xemul@openvz.org> writes:

>> +static __inline__ void scm_destroy_cred(struct scm_cookie *scm)
>> +{
>> +	put_pid(scm->pid);
>> +	scm->pid  = NULL;
>> +
>> +	if (scm->cred)
>> +		put_cred(scm->cred);
>> +	scm->cred = NULL;
>> +}
>> +
>>  static __inline__ void scm_destroy(struct scm_cookie *scm)
>>  {
>> +	scm_destroy_cred(scm);
>>  	if (scm && scm->fp)
>>  		__scm_destroy(scm);
>>  }
>
> I'm a bit worried by the "if (scm" check. It makes me think scm can
> be NULL here and thus scm_destroy_cred can oops.

Interesting point.  I just looked at all of the callers and scm
appears to always be valid.

Eric

