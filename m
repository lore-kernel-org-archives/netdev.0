From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH 11/14 v2] nes: OpenFabrics kernel verbs
Date: Wed, 31 Oct 2007 13:56:04 -0700
Message-ID: <adawst3f1gb.fsf@cisco.com>
References: <200710192023.l9JKNFov021830@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ewg@lists.openfabrics.org,
	general@lists.openfabrics.org
To: ggrundstrom@neteffect.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <200710192023.l9JKNFov021830@neteffect.com>
	(ggrundstrom@neteffect.com's message of "Fri,
	19 Oct 2007 15:23:15 -0500")
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

 > +/**
 > + * nes_post_send
 > + */
 > +static int nes_post_send(struct ib_qp *ibqp, struct ib_send_wr *ib_wr,
 > +		struct ib_send_wr **bad_wr)

 > ...

 > +			switch (ib_wr->opcode) {

 > ...

 > +					if (ib_wr->num_sge > nesdev->nesadapter->max_sge) {
 > +						err = -EINVAL;
 > +						break;
 > +					}

 > ...

 > +				default:
 > +					/* error */
 > +					err = -EINVAL;
 > +					break;

looks like if you detect an error while posting a work request, you
break out of the switch statement but just continue through the while
loop going through the list of work reuqests.  Which doesn't seem like
it will work very well.
