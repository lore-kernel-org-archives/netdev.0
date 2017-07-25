From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: don't zero out the info struct in bpf_obj_get_info_by_fd()
Date: Wed, 26 Jul 2017 01:29:50 +0200
Message-ID: <5977D46E.2070100@iogearbox.net>
References: <20170725221612.6937-1-jakub.kicinski@netronome.com>        <5977CD65.20504@iogearbox.net> <20170725161547.64d1cba5@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        alexei.starovoitov@gmail.com, kafai@fb.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41299 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751080AbdGYX3w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 19:29:52 -0400
In-Reply-To: <20170725161547.64d1cba5@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/26/2017 01:15 AM, Jakub Kicinski wrote:
> On Wed, 26 Jul 2017 00:59:49 +0200, Daniel Borkmann wrote:
>>> @@ -418,6 +420,8 @@ static void test_bpf_obj_id(void)
>>>    		nr_id_found++;
>>>
>>>    		err = bpf_obj_get_info_by_fd(prog_fd, &prog_info, &info_len);
>>> +		prog_infos[i].jited_prog_insns = 0;
>>> +		prog_infos[i].xlated_prog_insns = 0;
>>
>> Can you elaborate why this one above is needed?
>
> Ah, I removed the comment about it at the last minute.  The check below
> compares the info we get here with info we got reading the programs in
> the earlier loop - using memcmp().

Yep, makes sense. I mistook it for 'length' given it is not NULL but 0,
but that is due to __aligned_u64. ;) Anyway, thanks for clarifying.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
