From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Re: Bug in qeth in 2.6
Date: Thu, 4 Sep 2003 11:45:12 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030904114512.A12054@devserv.devel.redhat.com>
References: <OFCF0074F3.0CE8CF77-ONC1256D97.00308924-C1256D97.0030F005@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pete Zaitcev <zaitcev@redhat.com>, netdev@oss.sgi.com,
   Utz Bacher <utz.bacher@de.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Cornelia Huck <COHUCK@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <OFCF0074F3.0CE8CF77-ONC1256D97.00308924-C1256D97.0030F005@de.ibm.com>; from COHUCK@de.ibm.com on Thu, Sep 04, 2003 at 10:54:43AM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 04, 2003 at 10:54:43AM +0200, Cornelia Huck wrote:
> could you please elaborate what's exactly wrong with qeth_verify_dev()?
> 
> It has the same behaviour as in 2.4, and it looks correct to us...

2.4 was like this:

	result = 0;
	for (all in list) {
		if (something)
			result = QETH_VERIFY_IS_SOMETHING;
	}

2.6 is:

	result = 0;
	for (all in list) {
		result = (something)? QETH_VERIFY_IS_SOMETHING: foo();
	}

Results are different if two cards are present on the list
and the function is asked to verify the first card.

-- Pete
