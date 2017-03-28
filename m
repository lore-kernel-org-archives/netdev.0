From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 06/16] drivers, net, mlx5: convert mlx5_cq.refcount from
 atomic_t to refcount_t
Date: Tue, 28 Mar 2017 09:33:21 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFBE8AF@AcuExch.aculab.com>
References: <1490691403-4016-1-git-send-email-elena.reshetova@intel.com>
 <1490691403-4016-7-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "peterz@infradead.org" <peterz@infradead.org>,
 "matanb@mellanox.com" <matanb@mellanox.com>,
 "paulus@samba.org" <paulus@samba.org>, "nbd@openwrt.org" <nbd@openwrt.org>,
 "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
 "saeedm@mellanox.com" <saeedm@mellanox.com>,
 "ganeshgr@chelsio.com" <ganeshgr@chelsio.com>,
 Hans Liljestrand <ishkamiel@gmail.com>, David
 Windsor <dwindsor@gmail.com>, "keescook@chromium.org" <keescook@chromium.org>,
 "j@w1.fi" <j@w1.fi>, "ajk@comnets.uni-bremen.de" <ajk@comnets.uni-bremen.de>,
 "leonro@mellanox.com" <leonro@mellanox.com>,
 "matthias.bgg@gmail.com" <matthias.bgg@gmail.com>,
 "linux-hams@vger.kernel.org" <linux-hams@vger.kernel.org>,
 "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
 "blogic@openwrt.org" <blogic@openwrt.org>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 "linux-ppp@vger.kernel.org" <linux-
To: 'Elena Reshetova' <elena.reshetova@intel.com>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1490691403-4016-7-git-send-email-elena.reshetova@intel.com>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Elena Reshetova
> Sent: 28 March 2017 09:57
> 
> refcount_t type and corresponding API should be
> used instead of atomic_t when the variable is used as
> a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free
> situations.

I can't help feeling that you ought to find a scheme
that will detect extra decrements and extra increments
before the counter wraps 32 bits.

If an extra reference is requested every 100us it takes 4.8 days
for the counter to increment back to zero.
Simple tests aren't doing to find that - but it can easily happen
on a system that is running for several years.

	David
