From: Leon Romanovsky <leonro@leon.nu>
Subject: Re: [PATCH v4 09/16] IB/pvrdma: Add support for Completion Queues
Date: Sun, 18 Sep 2016 20:07:07 +0300
Message-ID: <20160918170707.GL2923@leon.nu>
References: <1473655766-31628-1-git-send-email-aditr@vmware.com>
 <1473655766-31628-10-git-send-email-aditr@vmware.com>
 <20160914124321.GE15800@yuval-lap.uk.oracle.com>
 <BLUPR0501MB836640F5ECEAB3A99CD82BFC5F00@BLUPR0501MB836.namprd05.prod.outlook.com>
 <20160915073611.GA3851@yuval-lap.uk.oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="9ToWwKEyhugL+MAz"
Cc: Adit Ranadive <aditr@vmware.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        pv-drivers <pv-drivers@vmware.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "Jorgen S. Hansen" <jhansen@vmware.com>,
        Aditya Sarwade <asarwade@vmware.com>,
        George Zhang <georgezhang@vmware.com>,
        Bryan Tan <bryantan@vmware.com>
To: Yuval Shaia <yuval.shaia@oracle.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160915073611.GA3851@yuval-lap.uk.oracle.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--9ToWwKEyhugL+MAz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Sep 15, 2016 at 10:36:12AM +0300, Yuval Shaia wrote:
> Hi Adit,
> Please see my comments inline.
>
> Besides that I have no more comment for this patch.
>
> Reviewed-by: Yuval Shaia <yuval.shaia@oracle.com>
>
> Yuval
>
> On Thu, Sep 15, 2016 at 12:07:29AM +0000, Adit Ranadive wrote:
> > On Wed, Sep 14, 2016 at 05:43:37 -0700, Yuval Shaia wrote:
> > > On Sun, Sep 11, 2016 at 09:49:19PM -0700, Adit Ranadive wrote:
> > > > +
> > > > +static int pvrdma_poll_one(struct pvrdma_cq *cq, struct pvrdma_qp
> > > **cur_qp,
> > > > +			   struct ib_wc *wc)
> > > > +{
> > > > +	struct pvrdma_dev *dev = to_vdev(cq->ibcq.device);
> > > > +	int has_data;
> > > > +	unsigned int head;
> > > > +	bool tried = false;
> > > > +	struct pvrdma_cqe *cqe;
> > > > +
> > > > +retry:
> > > > +	has_data = pvrdma_idx_ring_has_data(&cq->ring_state->rx,
> > > > +					    cq->ibcq.cqe, &head);
> > > > +	if (has_data == 0) {
> > > > +		if (tried)
> > > > +			return -EAGAIN;
> > > > +
> > > > +		/* Pass down POLL to give physical HCA a chance to poll. */
> > > > +		pvrdma_write_uar_cq(dev, cq->cq_handle |
> > > PVRDMA_UAR_CQ_POLL);
> > > > +
> > > > +		tried = true;
> > > > +		goto retry;
> > > > +	} else if (has_data == PVRDMA_INVALID_IDX) {
> > >
> > > I didn't went throw the entire life cycle of RX-ring's head and tail but you
> > > need to make sure that PVRDMA_INVALID_IDX error is recoverable one, i.e
> > > there is probability that in the next call to pvrdma_poll_one it will be fine.
> > > Otherwise it is an endless loop.
> >
> > We have never run into this issue internally but I don't think we can recover here
>
> I briefly reviewed the life cycle of RX-ring's head and tail and didn't
> caught any suspicious place that might corrupt it.
> So glad to see that you never encountered this case.
>
> > in the driver. The only way to recover would be to destroy and recreate the CQ
> > which we shouldn't do since it could be used by multiple QPs.
>
> Agree.
> But don't they hit the same problem too?
>
> > We don't have a way yet to recover in the device. Once we add that this check
> > should go away.
>
> To be honest i have no idea how to do that - i was expecting driver's vendors
> to come up with an ideas :)
> I once came up with an idea to force restart of the driver but it was
> rejected.
>
> >
> > The reason I returned an error value from poll_cq in v3 was to break the possible
> > loop so that it might give clients a chance to recover. But since poll_cq is not expected
> > to fail I just log the device error here. I can revert to that version if you want to break
> > the possible loop.
>
> Clients (ULPs) cannot recover from this case. They even do not check the
> reason of the error and treats any error as -EAGAIN.

It is because poll_one is not expected to fall.

>
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

--9ToWwKEyhugL+MAz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX3sm7AAoJEORje4g2clinRrwP/1EFDeDViJt15ncCnvxRxk/M
GxzKk8yfT7UqCv+ZX8kDIIm/o1RyLgmZov6SPm2ldXk63xfriWqe1RAVd120WTcM
ZaD+kum8bXtwPSOCqnSfPk3uN0CVWnxHPOXcculF10sR4UcMctGAP5IjLzmGV55l
xLZtnVbhaQEs7dpeAUYDk9h4+NOiedewb3YUaA/rsNp8+ceZB1jRTPX+JY5OBdEV
RDmHUo72m0sING0lRLOX7TWXv6xpOk2Jqq3r3SgzPAemI9FZynCWEhiGuF010dMW
R+uhA22NwOwobLXf7beBQ4/cgHm1PlUM7Cjkhx3sZb7N9+/01tCSI4kzIhtsOTfc
bdPs/LH2gNMdm8mj5NJCDXPRK47IMVVmJ9qysUEElM5ierPHby7Y2R2951cS8x1G
dM6VDVAw9YyBUNKK/yWfYRQMS/mYbmhBk4lZahp7Z96IaO3tMCo7Sncp28hQ5hm6
L8+za80kyotyR6TQ9zRHjLfZ4xVNH8Zru9lOyYl9IO+f0KsNTOTNu5AU+80q3PLG
pmXfyD8TItf5ldFwrfXr67ER1Nx2jGkJ3fhoD6KSry0krZguo5lilCSCz/HK4QB7
KL4uOSVr4sOft5gZtzvQC/ek3H7Onz6+JhVzWdhto/+zzpUsCQDgVlj4QTbPaFSO
CiVjr5sJf/59kVnuyG1V
=ll8U
-----END PGP SIGNATURE-----

--9ToWwKEyhugL+MAz--
