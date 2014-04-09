From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 2/3] staging: r8188eu: Fix case where ethtype was never
 obtained and always be checked against 0
Date: Wed, 9 Apr 2014 22:00:17 +0300
Message-ID: <20140409190017.GC26890@mwanda>
References: <1397059980-11942-1-git-send-email-Larry.Finger@lwfinger.net>
 <1397059980-11942-3-git-send-email-Larry.Finger@lwfinger.net>
 <20140409185152.GB26890@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org,
 Stable <stable@vger.kernel.org>, netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20140409185152.GB26890@mwanda>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 09, 2014 at 09:51:53PM +0300, Dan Carpenter wrote:
> > -	if (auth_alg == 2) {
> > +	if (auth_alg == dot11AuthAlgrthm_8021X) {
> > +		/* get ether_type */
> > +		ptr = ptr + pfhdr->attrib.hdrlen + LLC_HEADER_SIZE;
> > +		memcpy(&ether_type, ptr, 2);
> > +		ether_type = ntohs((unsigned short)ether_type);
> 
> This cast doesn't make sense.  u16 and unsigned short are the same
> thing.  Anyway, the "ether_type" should be declared as __be16 because
> it's network endian.
> 

OOps.  You mostly use ether_type as u16.  But the cast is still wrong it
should be:

		ether_type = ntohs((__be16)ether_type);

Or something.  You could use the be_tmp variable...  Doesn't this patch
introduce an unused variable warning?

regards,
dan carpenter
