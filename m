From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH 17/21] RDS/IB: Receive datagrams via IB
Date: Thu, 29 Jan 2009 13:47:03 -0800
Message-ID: <ada4ozhss2w.fsf@cisco.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
	<ada1vunt1sg.fsf@cisco.com> <49811278.3050806@oracle.com>
	<200901292202.28625.okir@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	general@lists.openfabrics.org
To: Olaf Kirch <okir@suse.de>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <200901292202.28625.okir@suse.de> (Olaf Kirch's message of "Thu,
	29 Jan 2009 22:02:28 +0100")
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

 > > > This is racy.  You check if you're at the limit, do the allocation, and
 > > > then increment the atomic rds_ib_allocation count.  So many threads can
 > > > pass the atomic_read() test and then take you over the limit.  If you
 > > > want to make it safe then you could do atomic_inc_return() and check if
 > > > that took you over the limit.
 > >
 > > Woah, yup, thanks.
 > 
 > The refill code used to be single-threaded; and I think it still is. So
 > this can't race I think

So you don't need the atomic op at all?

 - R.
