From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] [PATCH 09/13] QLogic VNIC: IB Multicast for
	Ethernet broadcast/multicast
Date: Thu, 15 May 2008 15:38:00 -0700
Message-ID: <ada7idvdwhj.fsf@cisco.com>
References: <20080430171028.31725.86190.stgit@localhost.localdomain>
	<20080430172025.31725.97795.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, amar.mudrankit@qlogic.com,
	general@lists.openfabrics.org, poornima.kamath@qlogic.com
To: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080430172025.31725.97795.stgit@localhost.localdomain>
	(Ramachandra K.'s message of "Wed, 30 Apr 2008 22:50:25 +0530")
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

 > +#define SET_MCAST_STATE_INVALID \
 > +do { \
 > +	viport->mc_info.state = MCAST_STATE_INVALID; \
 > +	viport->mc_info.mc = NULL; \
 > +	memset(&viport->mc_info.mgid, 0, sizeof(union ib_gid)); \
 > +} while (0);

Seems like this could be profitably implemented in C instead of CPP.

 > +		spin_lock_irqsave(&viport->mc_info.lock, flags);
 > +		viport->mc_info.state = MCAST_STATE_INVALID;
 > +		spin_unlock_irqrestore(&viport->mc_info.lock, flags);

This pattern makes me uneasy about the locking... setting the state
member will already be atomic, so what do you think you're protecting
against here by taking the lock?

 - R.
