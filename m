From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] packet: bail out of packet_snd() if L2 header creation
 fails
Date: Sun, 11 Jan 2015 22:38:13 +0100
Message-ID: <54B2ED45.7070001@redhat.com>
References: <1420999276-28225-1-git-send-email-cj@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, willemb@google.com, edumazet@google.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christoph Jaeger <cj@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420999276-28225-1-git-send-email-cj@linux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/11/2015 07:01 PM, Christoph Jaeger wrote:
> Due to a misplaced parenthesis, the expression
>
>    (unlikely(offset) < 0),
>
> which expands to
>
>    (__builtin_expect(!!(offset), 0) < 0),
>
> never evaluates to true. Therefore, when sending packets with
> PF_PACKET/SOCK_DGRAM, packet_snd() does not abort as intended
> if the creation of the layer 2 header fails.
>
> Spotted by Coverity - CID 1259975 ("Operands don't affect result").
>
> Fixes: 9c7077622dd9 ("packet: make packet_snd fail on len smaller than l2 header")
> Signed-off-by: Christoph Jaeger <cj@linux.com>

Thanks, Christoph!

Acked-by: Daniel Borkmann <dborkman@redhat.com>
