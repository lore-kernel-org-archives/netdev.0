From: Salam Noureddine <noureddine@arista.com>
Subject: Re: [PATCH v2 net-next 4/4] net: fib: avoid calling fib_flush for
 each device when doing batch close and unregister
Date: Sat, 6 Feb 2016 22:09:10 -0800
Message-ID: <CAO7SqHCj3Fq+CXz_y+4ou+JxSvyMgpyQNRjMfX=Zvow3knocpw@mail.gmail.com>
References: <1454628956-4803-1-git-send-email-noureddine@arista.com>
	<1454628956-4803-5-git-send-email-noureddine@arista.com>
	<56B4C7F2.1020109@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Julian Anastasov <ja@ssi.bg>,
	Network Development <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:33710 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbcBGGJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 01:09:11 -0500
Received: by mail-wm0-f50.google.com with SMTP id g62so95384480wme.0
        for <netdev@vger.kernel.org>; Sat, 06 Feb 2016 22:09:10 -0800 (PST)
In-Reply-To: <56B4C7F2.1020109@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 5, 2016 at 8:04 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 02/05/2016 02:35 AM, Salam Noureddine wrote:

>>
>>         if (event == NETDEV_UNREGISTER) {
>> -               fib_disable_ip(dev, event, true);
>> +               if (fib_sync_down_dev(dev, event, true))
>> +                       net->ipv4.needs_fib_flush = true;
>>                 rt_flush_dev(dev);
>>                 return NOTIFY_DONE;
>>         }
>>
>> +       if (event == NETDEV_UNREGISTER_BATCH || event ==
>> NETDEV_DOWN_BATCH) {
>> +               if (net->ipv4.needs_fib_flush) {
>> +                       fib_flush(net);
>> +                       net->ipv4.needs_fib_flush = false;
>> +               }
>> +               rt_cache_flush(net);
>> +               arp_ifdown_all();
>> +               return NOTIFY_DONE;
>> +       }
>> +
>
>
>    I'd convert to *switch* the above 2 *if*'s...
>
> [...]
>
> MBR, Sergei
>

I could do that.

Thanks,

Salam
