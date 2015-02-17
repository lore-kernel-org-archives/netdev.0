From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] ematch: Fix auto-loading of ematch modules.
Date: Tue, 17 Feb 2015 10:00:16 -0800
Message-ID: <CAHA+R7Os10B8KuBV0K9qp48zo2+=_aXUR-k5ocXjEWYqtq222w@mail.gmail.com>
References: <20150216150329.GB16798@zenon.in.qult.net>
	<20150216181315.GA15280@zenon.in.qult.net>
	<CAHA+R7McGmFtXpiEJkOV2Jjgy29kzpX7tTeprS7S0pY2m9mJBw@mail.gmail.com>
	<20150216185011.GA29935@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?UTF-8?Q?Ignacy_Gaw=C4=99dzki?=
	<ignacy.gawedzki@green-communications.fr>,
	Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:35330 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753348AbbBQSAQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 13:00:16 -0500
Received: by iecrl12 with SMTP id rl12so40424125iec.2
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2015 10:00:16 -0800 (PST)
In-Reply-To: <20150216185011.GA29935@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 16, 2015 at 10:50 AM, Ignacy Gaw=C4=99dzki
<ignacy.gawedzki@green-communications.fr> wrote:
> On Mon, Feb 16, 2015 at 10:36:06AM -0800, thus spake Cong Wang:
>> On Mon, Feb 16, 2015 at 10:13 AM, Ignacy Gaw=C4=99dzki
>> <ignacy.gawedzki@green-communications.fr> wrote:
>> > In tcf_em_validate(), when calling tcf_em_lookup(), don't put the =
resulting
>> > pointer directly into em->ops, if the function is to possibly retu=
rn -EAGAIN
>> > after module auto-loading.  Otherwise, module_put() will be called=
 by
>> > tcf_em_tree_destroy() on em->ops->owner, while it has already been=
 called by
>> > tcf_em_validate() before return.
>> >
>>
>> Or simply reset em->ops to NULL after module_put()?
>
> Yeah, why not.  I just got my inspiration from what's done in cls_api=
=2Ec and
> act_api.c.  What do you think, should the same simplification be appl=
ied to
> cls_api.c?
>

I prefer the smaller change, we don't have to align with cls_api.c.
Yeah, you can always clean it up for net-next.

Thanks.
