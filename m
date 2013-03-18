From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sctp: hang in sctp_remaddr_seq_show
Date: Mon, 18 Mar 2013 08:25:40 -0700
Message-ID: <1363620340.29475.132.camel@edumazet-glaptop>
References: <51434D78.9030308@oracle.com>
	 <20130318110415.GA9478@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sasha Levin <sasha.levin@oracle.com>, vyasevich@gmail.com,
	sri@us.ibm.com, "David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jones <davej@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130318110415.GA9478@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-03-18 at 07:04 -0400, Neil Horman wrote:

> I'm not sure why the process would never get back to the schedule, but looking
> at the sctp_remaddr_seq_show function, I think that we should convert this
> sequence:
> 	sctp_local_bh_disable();
> 	read_lock(&head->lock);
> 	rcu_read_lock();
> 
> to this:
> 	read_lock(&head->lock);
> 	rcu_read_lock_bh();
> 
> Neil

I dont think so.

BH needs to be disabled before read_lock(&head->lock);

or else, write_lock() could deadlock (assuming it can be called from BH)
