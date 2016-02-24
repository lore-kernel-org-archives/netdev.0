From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next v2 2/2] net_sched: add network namespace support
 for tc actions
Date: Wed, 24 Feb 2016 09:21:55 -0800
Message-ID: <CAM_iQpWXbEtv6q-Uj9O+-HPDdBkMj27qo0TYXjzGoQm9cGgicQ@mail.gmail.com>
References: <1456185473-25403-1-git-send-email-xiyou.wangcong@gmail.com>
	<1456185473-25403-3-git-send-email-xiyou.wangcong@gmail.com>
	<56CC5B35.4060408@mojatatu.com>
	<CAM_iQpVVe28XUkSfR1OhwMq6mgJVQ_zcPJn+xmLpb_YDy0wsDg@mail.gmail.com>
	<56CDADDB.5070003@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:33065 "EHLO
	mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752947AbcBXRV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 12:21:56 -0500
Received: by mail-yw0-f179.google.com with SMTP id u200so20823226ywf.0
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 09:21:56 -0800 (PST)
In-Reply-To: <56CDADDB.5070003@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 24, 2016 at 5:19 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-02-23 05:23 PM, Cong Wang wrote:
>>
>> On Tue, Feb 23, 2016 at 5:14 AM, Jamal Hadi Salim <jhs@mojatatu.com>
>> wrote:
>
>
>>> It doesnt seem neccessary to have hinfo in tc_action. Quick scan:
>>> __tcf_hash_release() seems to be the only other place that uses it.
>>> And the callers to that appear capable of passing the struct
>>> net or tn  which eventually propagates up...
>>
>>
>> The tcf_action_destroy() callchain still can't find out hinfo yet.
>>
>
> Did you mean something else or am i missing the obvious?
> I am looking at the call sites for tcf_action_destroy():
> -tc_dump_tfilter() has access to *net
> -tcf_exts_change() - one level lower it has access to *net; i think you
> added this to your patch too.
> -tcf_action_init() has *net.

Well, having net is not enough, we still need net_id to retrieve hinfo,
and net_id is per module... So it is not easy at all.
