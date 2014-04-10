From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/3] staging: r8188eu: Fix case where ethtype was never
 obtained and always be checked against 0
Date: Thu, 10 Apr 2014 09:14:56 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6F4388@AcuExch.aculab.com>
References: <1397059980-11942-1-git-send-email-Larry.Finger@lwfinger.net>
 <1397059980-11942-3-git-send-email-Larry.Finger@lwfinger.net>
 <20140409185152.GB26890@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 Stable <stable@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Dan Carpenter' <dan.carpenter@oracle.com>, Larry Finger
 <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140409185152.GB26890@mwanda>
Content-Language: en-US
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

From: Dan Carpenter
...
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

Is it worth doing just:
	ether_type = ptr[0] << 8 | ptr[1];
Or, if 'ptr' can't be misaligned, just reading a BE short.
If the compiler doesn't inline memcpy() the above code is horrid.

Are there MD inline functions for reading misaligned 16/32 bit date
with specific endianness?

	David
