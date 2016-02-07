From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 net-next 4/4] net: fib: avoid calling fib_flush for
 each device when doing batch close and unregister
Date: Sun, 7 Feb 2016 13:24:47 +0300
Message-ID: <56B71B6F.1010708@cogentembedded.com>
References: <1454628956-4803-1-git-send-email-noureddine@arista.com>
 <1454628956-4803-5-git-send-email-noureddine@arista.com>
 <56B4C7F2.1020109@cogentembedded.com>
 <CAO7SqHCj3Fq+CXz_y+4ou+JxSvyMgpyQNRjMfX=Zvow3knocpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Julian Anastasov <ja@ssi.bg>,
	Network Development <netdev@vger.kernel.org>
To: Salam Noureddine <noureddine@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:34119 "EHLO
	mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753485AbcBGKYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 05:24:51 -0500
Received: by mail-lf0-f44.google.com with SMTP id j78so80504991lfb.1
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 02:24:50 -0800 (PST)
In-Reply-To: <CAO7SqHCj3Fq+CXz_y+4ou+JxSvyMgpyQNRjMfX=Zvow3knocpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/7/2016 9:09 AM, Salam Noureddine wrote:

>>>
>>>          if (event == NETDEV_UNREGISTER) {
>>> -               fib_disable_ip(dev, event, true);
>>> +               if (fib_sync_down_dev(dev, event, true))
>>> +                       net->ipv4.needs_fib_flush = true;
>>>                  rt_flush_dev(dev);
>>>                  return NOTIFY_DONE;
>>>          }
>>>
>>> +       if (event == NETDEV_UNREGISTER_BATCH || event ==
>>> NETDEV_DOWN_BATCH) {
>>> +               if (net->ipv4.needs_fib_flush) {
>>> +                       fib_flush(net);
>>> +                       net->ipv4.needs_fib_flush = false;
>>> +               }
>>> +               rt_cache_flush(net);
>>> +               arp_ifdown_all();
>>> +               return NOTIFY_DONE;
>>> +       }
>>> +
>>
>>
>>     I'd convert to *switch* the above 2 *if*'s...

> I could do that.

    Please do it, in this patch.

> Thanks,
>
> Salam

MBR, Sergei
