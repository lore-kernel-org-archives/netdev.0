From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [ofa-general] InfiniBand/RDMA merge plans for 2.6.24
Date: Thu, 13 Sep 2007 15:59:18 -0700
Message-ID: <1189724358.9540.113.camel@dell>
References: <adahclymos8.fsf@cisco.com>
	<46E97BB0.9030106@opengridcomputing.com> <adaps0ml18e.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, anilgv@broadcom.com, uri@broadcom.com
To: "Roland Dreier" <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adaps0ml18e.fsf@cisco.com>
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

On Thu, 2007-09-13 at 14:11 -0700, Roland Dreier wrote:

> 
> I've been meaning to track down the bnx2 iscsi offload patch to look
> and see if this issue is addressed, since the same problem seems to
> exist: it seems an iscsi connection and a main stack tcp connection
> might share the same 4-tuple unless something is done to avoid that
> happening.
> 

iSCSI does not do passive listens, only active connections to the
target.  But you're right, the port space is still shared between iSCSI
and the main stack.  We currently rely on user apps binding to the main
stack to reserve certain ephemeral ports, and telling the iSCSI driver
which ports to use.
