From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: add reverse binding for tc class
Date: Wed, 30 Aug 2017 16:15:03 -0700
Message-ID: <CAM_iQpW26pfWE-UyGQ6B=auhOw+Hk-ON4sck6hz0Wx48JMdYxQ@mail.gmail.com>
References: <20170830213036.24250-1-xiyou.wangcong@gmail.com>
 <59A732B8.6020405@iogearbox.net> <CAM_iQpU9B71C5cWs969k464T7HvNhcwps7NYNQx8Q3KCijOfnA@mail.gmail.com>
 <59A73AAE.509@iogearbox.net> <59A73FFC.5070803@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36266 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751613AbdH3XPY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 19:15:24 -0400
Received: by mail-wm0-f44.google.com with SMTP id u126so18403974wmg.1
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 16:15:24 -0700 (PDT)
In-Reply-To: <59A73FFC.5070803@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 30, 2017 at 3:45 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 08/31/2017 12:22 AM, Daniel Borkmann wrote:
>>
>> The prog->res.classid is the default one, but can be overridden
>> later depending on the specified program. cls_bpf_classify() does
>> after prog return (filter_res holds return code):
>>
>>      [...]
>>          if (filter_res == 0)
>>              continue;
>>          if (filter_res != -1) {
>>              res->class   = 0;
>>              res->classid = filter_res;
>>          } else {
>>              *res = prog->res;
>>          }
>>      [...]
>>
>> Meaning in case of a match (-1), we use the default bound one,
>> but prog may as well return an alternative found classid if it
>> wants to. So both versions are possible.
>
>
> But even for that case your patch looks fine to me actually, since
> for dynamic classid we set class to 0. No objections from my side
> then.

Sounds good. Then I will leave it as it is.

Thanks for explanation.
