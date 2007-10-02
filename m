From: "Sean Hefty" <sean.hefty@intel.com>
Subject: RE: [ofa-general] InfiniBand/RDMA merge plans for 2.6.24
Date: Tue, 2 Oct 2007 11:50:04 -0700
Message-ID: <000601c80525$0b661f30$ff0da8c0@amr.corp.intel.com>
References: <adahclymos8.fsf@cisco.com><000401c7f632$c993e8e0$65cc180a@amr.corp.intel.com><adatzpyl1mm.fsf@cisco.com><000001c7f6f7$074584e0$9c98070a@amr.corp.intel.com>
	<adaprzxgyoi.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: "'Roland Dreier'" <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adaprzxgyoi.fsf@cisco.com>
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

>Umm... this is a difficult situation for me to merge the changes then.
>We're changing the CM retry behavior blind here.  How do we know that
>the MRA changes don't make the scalability issue worse?

What's currently upstream doesn't work for Intel MPI on our larger clusters.
The connection requests time out on the active side before the passive side can
respond.

The OFED release works because it provides a kernel patch to make the timeout a
module parameter.  I'm trying to avoid adding a module parameter, and the MRA is
designed for this situation.

I tested this by simulating a slow passive side responder, and it worked as
expected for those tests.  Using an MRA does add another MAD to the CM exchange,
which is why it is sent only after seeing a duplicate request.  Alternatively,
we can take the OFED module parameter patch.

- Sean
