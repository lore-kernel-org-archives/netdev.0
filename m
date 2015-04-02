From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH iproute2 -next] tc, bpf: finalize eBPF support for cls
 and act front-end
Date: Thu, 02 Apr 2015 09:14:07 -0700
Message-ID: <551D6ACF.3090101@plumgrid.com>
References: <d9a577418790f99130c1cb20dc01cf50c2d6a7da.1427754287.git.daniel@iogearbox.net> <1427933636.1888890.248325033.0A76BE0D@webmail.messagingengine.com> <551C8C2D.5060504@iogearbox.net> <1427934556.1892386.248333013.431CD73B@webmail.messagingengine.com> <551D17B4.2090903@iogearbox.net> <1427974255.2093319.248499373.05D36231@webmail.messagingengine.com> <551D3156.9030407@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, tgraf@suug.ch, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:34760 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbbDBQOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 12:14:04 -0400
Received: by iedfl3 with SMTP id fl3so81597847ied.1
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 09:14:03 -0700 (PDT)
In-Reply-To: <551D3156.9030407@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/2/2015 5:08 AM, Daniel Borkmann wrote:
> On 04/02/2015 01:30 PM, Hannes Frederic Sowa wrote:
>>> ... perhaps such a built-in fake device for retrieving bpf map fds
>>> might be interesting, e.g. exec 4<>/dev/bpf/<obj-file>/<map-name> if
>>> that has been given to bash?
>>>
>>> Anyway, I think to have some utility for shell scripts, as you
>>> suggest, certainly sounds interesting!
>>
>> All file descriptors will be inherited by exec as long as the O_CLOEXEC
>> flag wasn't specified on them. So you can retrieve the fds via af_unix
>> and just exec a new shell. The file descriptors will stay open and you
>> can pass the numbers of the fds via environment. This wouldn't need
>> changes to bash or kernel.
>
> Okay, I will give it a try. Thanks!

I think even if it's little awkward to do it in user space, it's better
than adding stuff to kernel. This /dev/bpf/obj-file/map-name or sysfs
might start hitting scalability issues when we try to load thousands
of bpf programs.
