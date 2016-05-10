From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Tue, 10 May 2016 09:08:59 -0700
Message-ID: <1462896539.23934.93.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1462886866.git.pabeni@redhat.com>
	 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462896230.6687.74.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	linux-kernel@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462896230.6687.74.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-05-10 at 18:03 +0200, Paolo Abeni wrote:

> If a single core host is under network flood, i.e. ksoftirqd is
> scheduled and it eventually (after processing ~640 packets) will let the
> user space process run. The latter will execute a syscall to receive a
> packet, which will have to disable/enable bh at least once and that will
> cause the processing of another ~640 packets. To receive a single packet
> in user space, the kernel has to process more than one thousand packets.

Looks you found the bug then. Have you tried to fix it ?
