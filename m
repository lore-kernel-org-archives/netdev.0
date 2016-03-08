From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] sctp: fix copying more bytes than expected in
 sctp_add_bind_addr
Date: Tue, 08 Mar 2016 15:05:17 -0500 (EST)
Message-ID: <20160308.150517.1036872213180279520.davem@davemloft.net>
References: <c774cc7c0b589b8fe979fea7bf1aa6748eecd2f0.1457443254.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com, nhorman@tuxdriver.com,
	vyasevich@gmail.com, linux-sctp@vger.kernel.org,
	linux-kernel@vger.kernel.org, syzkaller@googlegroups.com,
	kcc@google.com, glider@google.com, sasha.levin@oracle.com,
	edumazet@google.com, lkp@intel.com, fengguang.wu@intel.com
To: marcelo.leitner@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c774cc7c0b589b8fe979fea7bf1aa6748eecd2f0.1457443254.git.marcelo.leitner@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Tue,  8 Mar 2016 10:34:28 -0300

> Dmitry reported that sctp_add_bind_addr may read more bytes than
> expected in case the parameter is a IPv4 addr supplied by the user
> through calls such as sctp_bindx_add(), because it always copies
> sizeof(union sctp_addr) while the buffer may be just a struct
> sockaddr_in, which is smaller.
> 
> This patch then fixes it by limiting the memcpy to the min between the
> union size and a (new parameter) provided addr size. Where possible this
> parameter still is the size of that union, except for reading from
> user-provided buffers, which then it accounts for protocol type.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Tested-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied, thanks.
