From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCH] selftests: bpf: add check for ip XDP redirect
Date: Fri, 11 Aug 2017 06:35:04 -0700
Message-ID: <CALDO+SamWnQWgt984EjiqifR=RMZaAid1OdaJ-DrjrRKd9=3Ow@mail.gmail.com>
References: <1502409753-27516-1-git-send-email-u9012063@gmail.com> <598D9597.2030907@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35955 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752883AbdHKNfp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 09:35:45 -0400
Received: by mail-pg0-f65.google.com with SMTP id y129so3163248pgy.3
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 06:35:45 -0700 (PDT)
In-Reply-To: <598D9597.2030907@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

thanks! I will fix it and re-submit.
William

On Fri, Aug 11, 2017 at 4:31 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 08/11/2017 02:02 AM, William Tu wrote:
>>
>> Kernel test robot reports error when running test_xdp_redirect.sh.
>> Check if ip tool supports xdpgeneric, if not, skip the test.
>>
>> Signed-off-by: William Tu <u9012063@gmail.com>
>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: John Fastabend <john.fastabend@gmail.com>
>> ---
>>   tools/testing/selftests/bpf/test_xdp_redirect.sh | 5 +++++
>>   1 file changed, 5 insertions(+)
>>
>> diff --git a/tools/testing/selftests/bpf/test_xdp_redirect.sh
>> b/tools/testing/selftests/bpf/test_xdp_redirect.sh
>> index d8c73ed6e040..c5a8b7173c12 100755
>> --- a/tools/testing/selftests/bpf/test_xdp_redirect.sh
>> +++ b/tools/testing/selftests/bpf/test_xdp_redirect.sh
>> @@ -23,6 +23,11 @@ cleanup()
>>         ip netns del ns2 2> /dev/null
>>   }
>>
>> +ip link set dev lo xdpgeneric off 2>/dev/null > /dev/null
>> +if [ $? -ne 0 ];then
>> +        echo "selftests: [SKIP] Could not run test without the ip
>> xdpgeneric support"
>> +        exit 0
>
>
> Small nit: could you make that indent consistently as tabs
> like in your cleanup() function slightly further above?
>
> Other than that (+ subject should also be [PATCH net-next]):
>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
