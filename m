From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v2 1/3] bpf: Use 1<<16 as ceiling for immediate alignment
 in verifier.
Date: Wed, 17 May 2017 18:18:55 -0700
Message-ID: <a2936291-b279-0b3f-94be-73cb1bbaa47e@fb.com>
References: <f2bff26d-8b4d-c6a2-23c9-9db198569e40@fb.com>
 <50288778-10f6-7201-c979-bfe4635831fc@solarflare.com>
 <e873f261-e1c1-c344-3d72-254623e0c91a@solarflare.com>
 <20170517.201633.1413407173876329751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <alexei.starovoitov@gmail.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:35266 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753916AbdERBTS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 21:19:18 -0400
In-Reply-To: <20170517.201633.1413407173876329751.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/17/17 5:16 PM, David Miller wrote:
> BTW, we track something similar already in reg->imm which tracks how
> many high order bits are known to be cleared in the register.  It is
> used to avoid potential overflow for packet pointer accesses.  I bet
> we can subsume that into this facility as well.

yeah, reg->imm tracks zero upper bits in very simplistic way.
For alignment checking it seems we need to track lower zeros
and ones. If Edward's algorithm can be adopted to track both
that would be double win indeed.
