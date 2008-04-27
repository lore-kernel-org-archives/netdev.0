From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [ofa-general] [PATCH 2.6.26 3/3] RDMA/cxgb3: Support peer-2-peer
	connection setup.
Date: Sun, 27 Apr 2008 11:44:43 -0500
Message-ID: <4814AD7B.2060006@opengridcomputing.com>
References: <20080427155456.31018.22282.stgit@dell3.ogc.int>	<20080427160010.31018.67436.stgit@dell3.ogc.int>
	<adatzhn2r5z.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org,
	linux-kernel@vger.kernel.org, divy@chelsio.com
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adatzhn2r5z.fsf@cisco.com>
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



Roland Dreier wrote:
> What are the interoperability implications of this?
> 
> Looking closer I see that iw_nes has the send_first module parameter.
> How does this interact with that?
> 

It doesn't...yet.  But we wanted to enable these applications for 
chelsio now and get the low level fw and driver changes done first and 
tested.

> I guess it's fine to apply this, but do we have a plan for how we want
> to handle this issue in the long-term?
> 

Yes!  If you'll recall, we had a thread on the ofa general list 
discussing how to enhance the MPA negotiation so peers can indicate 
whether they want/need the RTR and what type of RTR (0B read, 0B write, 
or 0B send) should be sent.  This will be done by standardizing a few 
bits of the private data in order to negotiate all this.  The rdma-cma 
API will be extended so applications will have to request this 
peer-2-peer model since it adds overhead to the connection setup.

I plan to do this work for 2.6.27/ofed-1.4.  I think it was listed in 
Felix's talk at Sonoma.  This work (design, API, and code changes 
affecting core and placing requirements on iwarp providers) will be 
posted as RFC changes to get everyones feedback as soon as I get 
something going.

Does that sound ok?


Steve.
