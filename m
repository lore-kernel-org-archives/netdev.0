From: Arnd Bergmann <arnd.bergmann@de.ibm.com>
Subject: Re: [PATCH 1/6] ehea: interface to network stack
Date: Mon, 14 Aug 2006 18:59:47 +0200
Message-ID: <200608141859.48868.arnd.bergmann@de.ibm.com>
References: <44D99EFC.3000105@de.ibm.com> <20060814143842.GM479@krispykreme>
	<44E09A19.9050205@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <tklein@de.ibm.com>, netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>, Anton Blanchard <anton@samba.org>,
	=?iso-8859-1?q?J=F6rn_Engel?= <joern@wohnheim.fh-wedel.de>,
	Marcus Eder <meder@de.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: linuxppc-dev@ozlabs.org
In-Reply-To: <44E09A19.9050205@de.ibm.com>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Monday 14 August 2006 17:43, Jan-Bernd Themann wrote:
> as our queue size is always a power of 2, we simply use:
> i++;
> i &= (ringbufferlength - 1)
> 
> So we can get along without the if.
> 

The recommended (by Linus) way for dealing with ring buffers
like that is to always read the counter through an accessor
and don't care about the overflow when updating it.

You can write small access functions for that:

struct my_struct {
	...
	unsigned rbuf_index;
	unsigned rbuf_mask;
	...
};

static inline unsigned int my_index(struct my_struct *p)
{
	return p->rb_index & p->rb_mask;
}

static inline unsigned int my_index_next(struct my_struct *p)
{
	return (++p->rb_index) & p->rb_mask;
}

	Arnd <><
