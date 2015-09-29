From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: unregister_netdevice warnings when deleting netns
Date: Tue, 29 Sep 2015 01:44:49 -0500
Message-ID: <87mvw54tcu.fsf@x220.int.ebiederm.org>
References: <CAGGTERmzF7oYABWUR+6UhddpOCtpkciVUMUOU-OcPkQvMznS8Q@mail.gmail.com>
	<alpine.LFD.2.11.1509282202270.7276@ja.home.ssi.bg>
	<8737xy5is2.fsf@x220.int.ebiederm.org>
	<CAGGTERk3G=q09i0v2=Yo+2CQiwSn3qyhTq7ehw7A9ez0mqK=vQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Julian Anastasov <ja@ssi.bg>, NETDEV <netdev@vger.kernel.org>
To: Anand Gurram <anandarao.gurram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:33105 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755479AbbI2Gwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 02:52:40 -0400
In-Reply-To: <CAGGTERk3G=q09i0v2=Yo+2CQiwSn3qyhTq7ehw7A9ez0mqK=vQ@mail.gmail.com>
	(Anand Gurram's message of "Tue, 29 Sep 2015 11:59:57 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anand Gurram <anandarao.gurram@gmail.com> writes:

>>If the message just spits out a few times and then goes away it simply
>>means that something is taking a while to cleanup and drop it's
>>reference.
>
> The message just spits out few times and then goes away, I am trying
> to debug why cleanup is taking long,
> and where it is still referenced. Any pointers in debugging such
> issues will be of great help.

The one thing I have done in the past is to instrument dev_hold
and dev_put and look where in the code the stragglers are coming from
(when I can reproduce the issue reliably).

Sometimes people have addressed this class of issue with code review,
but with a slow cleanup you can't catch this by finding a missing
dev_put.

It takes some creativity to find these as people rarely make the same
mistake twice.

Eric
