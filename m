From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v2 net-next 0/8] Introduce bpf ID
Date: Thu, 1 Jun 2017 07:55:47 -0600
Message-ID: <3f269312-efd4-86fc-e8e2-814af5898648@gmail.com>
References: <cover.1496256722.git.kafai@fb.com>
 <20170531192256.0e0d0ce1@cakuba.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, kernel-team@fb.com
To: Jakub Kicinski <kubakici@wp.pl>, Martin KaFai Lau <kafai@fb.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36761 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751083AbdFANzz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 09:55:55 -0400
Received: by mail-it0-f67.google.com with SMTP id i206so6331696ita.3
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 06:55:55 -0700 (PDT)
In-Reply-To: <20170531192256.0e0d0ce1@cakuba.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/31/17 8:22 PM, Jakub Kicinski wrote:
> On Wed, 31 May 2017 11:58:54 -0700, Martin KaFai Lau wrote:
>> This patch series:
>> 1) Introduce ID for both bpf_prog and bpf_map.
>> 2) Add bpf commands to iterate the prog IDs and map
>>    IDs of the system.
>> 3) Add bpf commands to get a prog/map fd from an ID
>> 4) Add bpf command to get prog/map info from a fd.
>>    The prog/map info is a jump start in this patchset
>>    and it is not meant to be a complete list.  They can
>>    be extended in the future patches.
> 
> Hi!  IIUC there were plans at some point to store the BPF byte code in
> the kernel, the way it was loaded from the user space and before it
> went through the verifier.  Are you still planning on implementing that?
> It would be handy for offloads to have the original byte code, things
> like call inlining make translations of maps calls a bit challenging,
> since we try to run through the verifier again..
> 

Save the instructions:
https://github.com/dsahern/linux/commit/5315578db7b0886a3e8e3bef6a56e828ae2bd2c4

Let userspace read it back:
https://github.com/dsahern/linux/commit/619982064b9b582fc5d4a504feffca1730610c4e

One more in between in the branch:
https://github.com/dsahern/linux/tree/bpf/retrieve-bpf-wip

Now that the id code is in, it needs to be returned on link dumps, route
dumps, etc and accessible via fdinfo. The id can be turned into an fd
and the fd read using the above patches.
