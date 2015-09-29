From: Anand Gurram <anandarao.gurram@gmail.com>
Subject: Re: unregister_netdevice warnings when deleting netns
Date: Tue, 29 Sep 2015 21:42:57 +0530
Message-ID: <CAGGTERkduFPmoiRJ+oUQ02kXe+dbOW=5e9W3f71=9hTjG_amVA@mail.gmail.com>
References: <CAGGTERmzF7oYABWUR+6UhddpOCtpkciVUMUOU-OcPkQvMznS8Q@mail.gmail.com>
	<alpine.LFD.2.11.1509282202270.7276@ja.home.ssi.bg>
	<8737xy5is2.fsf@x220.int.ebiederm.org>
	<CAGGTERk3G=q09i0v2=Yo+2CQiwSn3qyhTq7ehw7A9ez0mqK=vQ@mail.gmail.com>
	<87mvw54tcu.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Julian Anastasov <ja@ssi.bg>, NETDEV <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:33914 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932797AbbI2QM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 12:12:58 -0400
Received: by ykdg206 with SMTP id g206so11779609ykd.1
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 09:12:57 -0700 (PDT)
In-Reply-To: <87mvw54tcu.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Julian and Eric

I tried both the patches which you have suggested, the issue is still
seen, I am observing same warning message thrown on the console
  "unregister_netdevice: waiting for lo to become free. Usage count = 1".


>Sometimes people have addressed this class of issue with code review,
>but with a slow cleanup you can't catch this by finding a missing
>dev_put.

Yeah, currently since slow cleanup is happening I am unable to trace
just by having count for dev_hold and dev_put.


Actually at the time of tearing down the name space there is an active
TCP connection present.
When this TCP connection is not present then we are not seeing this issue.

Any additional ideas and suggestions on debugging in above scenario?

Best Regards,
Anand

On Tue, Sep 29, 2015 at 12:14 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Anand Gurram <anandarao.gurram@gmail.com> writes:
>
>>>If the message just spits out a few times and then goes away it simply
>>>means that something is taking a while to cleanup and drop it's
>>>reference.
>>
>> The message just spits out few times and then goes away, I am trying
>> to debug why cleanup is taking long,
>> and where it is still referenced. Any pointers in debugging such
>> issues will be of great help.
>
> The one thing I have done in the past is to instrument dev_hold
> and dev_put and look where in the code the stragglers are coming from
> (when I can reproduce the issue reliably).
>
> Sometimes people have addressed this class of issue with code review,
> but with a slow cleanup you can't catch this by finding a missing
> dev_put.
>
> It takes some creativity to find these as people rarely make the same
> mistake twice.
>
> Eric
