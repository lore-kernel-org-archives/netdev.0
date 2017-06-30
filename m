From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v5 01/16] bpf: BPF support for sock_ops
Date: Sat, 01 Jul 2017 01:31:42 +0200
Message-ID: <5956DF5E.6000803@iogearbox.net>
References: <20170630200706.4183158-1-brakmo@fb.com> <20170630200706.4183158-2-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56983 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751189AbdF3Xbq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 19:31:46 -0400
In-Reply-To: <20170630200706.4183158-2-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/30/2017 10:06 PM, Lawrence Brakmo wrote:
> Created a new BPF program type, BPF_PROG_TYPE_SOCK_OPS, and a corresponding
> struct that allows BPF programs of this type to access some of the
> socket's fields (such as IP addresses, ports, etc.). It uses the
> existing bpf cgroups infrastructure so the programs can be attached per
> cgroup with full inheritance support. The program will be called at
> appropriate times to set relevant connections parameters such as buffer
> sizes, SYN and SYN-ACK RTOs, etc., based on connection information such
> as IP addresses, port numbers, etc.
>
> Alghough there are already 3 mechanisms to set parameters (sysctls,
> route metrics and setsockopts), this new mechanism provides some
> distinct advantages. Unlike sysctls, it can set parameters per
> connection. In contrast to route metrics, it can also use port numbers
> and information provided by a user level program. In addition, it could
> set parameters probabilistically for evaluation purposes (i.e. do
> something different on 10% of the flows and compare results with the
> other 90% of the flows). Also, in cases where IPv6 addresses contain
> geographic information, the rules to make changes based on the distance
> (or RTT) between the hosts are much easier than route metric rules and
> can be global. Finally, unlike setsockopt, it oes not require
> application changes and it can be updated easily at any time.
[...]
>
> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
