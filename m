From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: Restore RFC5961-compliant behavior for SYN packets
Date: Fri, 21 Nov 2014 13:55:12 -0500
Message-ID: <CADVnQy=X2EihoNSQoDS0Ebviq9RZSNgaiJx7UHu+UZWhp-SuAQ@mail.gmail.com>
References: <1416524993-26228-1-git-send-email-calvinowens@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Eric Dumazet <edumazet@google.com>, kernel-team@fb.com,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Calvin Owens <calvinowens@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416524993-26228-1-git-send-email-calvinowens@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 20, 2014 at 6:09 PM, Calvin Owens <calvinowens@fb.com> wrote:
> Commit c3ae62af8e755 ("tcp: should drop incoming frames without ACK
> flag set") was created to mitigate a security vulnerability in which a
> local attacker is able to inject data into locally-opened sockets by
> using TCP protocol statistics in procfs to quickly find the correct
> sequence number.
>
> This broke the RFC5961 requirement to send a challenge ACK in response
> to spurious RST packets, which was subsequently fixed by commit
> 7b514a886ba50 ("tcp: accept RST without ACK flag").
>
> Unfortunately, the RFC5961 requirement that spurious SYN packets be
> handled in a similar manner remains broken.
>
> RFC5961 section 4 states that:
>
>    ... the handling of the SYN in the synchronized state SHOULD be
>    performed as follows:
>
>    1) If the SYN bit is set, irrespective of the sequence number, TCP
>       MUST send an ACK (also referred to as challenge ACK) to the remote
>       peer:
>
>       <SEQ=SND.NXT><ACK=RCV.NXT><CTL=ACK>
>
>       After sending the acknowledgment, TCP MUST drop the unacceptable
>       segment and stop processing further.
>
>    By sending an ACK, the remote peer is challenged to confirm the loss
>    of the previous connection and the request to start a new connection.
>    A legitimate peer, after restart, would not have a TCB in the
>    synchronized state.  Thus, when the ACK arrives, the peer should send
>    a RST segment back with the sequence number derived from the ACK
>    field that caused the RST.
>
>    This RST will confirm that the remote peer has indeed closed the
>    previous connection.  Upon receipt of a valid RST, the local TCP
>    endpoint MUST terminate its connection.  The local TCP endpoint
>    should then rely on SYN retransmission from the remote end to
>    re-establish the connection.
>
> This patch lets SYN packets through the discard added in c3ae62af8e755,
> so that spurious SYN packets are properly dealt with as per the RFC.
>
> The challenge ACK is sent unconditionally and is rate-limited, so the
> original vulnerability is not reintroduced by this patch.
>
> Signed-off-by: Calvin Owens <calvinowens@fb.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
