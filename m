From: Roland Dreier <rdreier@cisco.com>
Subject: [ofa-general] Re: [PATCH v2 12/13] QLogic VNIC: Driver Kconfig and
	Makefile.
Date: Sun, 25 May 2008 15:43:56 -0700
Message-ID: <adamyme57ir.fsf@cisco.com>
References: <20080519102843.12355.832.stgit@localhost.localdomain>
	<20080519103730.12355.14730.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, poornima.kamath@qlogic.com,
	general@lists.openfabrics.org, amar.mudrankit@qlogic.com
To: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080519103730.12355.14730.stgit@localhost.localdomain>
	(Ramachandra K.'s message of "Mon, 19 May 2008 16:07:30 +0530")
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

 > +config INFINIBAND_QLGC_VNIC_DEBUG
 > +	bool "QLogic VNIC Verbose debugging"
 > +	depends on INFINIBAND_QLGC_VNIC
 > +	default n
 > +	---help---
 > +	  This option causes verbose debugging code to be compiled
 > +	  into the QLogic VNIC driver.  The output can be turned on via the
 > +	  vnic_debug module parameter.

I think I mentioned this before, but... if you default this option to
'n', then all distributions will build your module with the option off.
And if someone is having problems, they will be forced to rebuild their
kernel to get debug output, which is a heavy burden for most users.

Much better to do something like what I ended up doing for mthca, which
is to have the option on unless someone specifically enables
CONFIG_EMBEDDED and goes out of their way to disable it:

	config INFINIBAND_MTHCA_DEBUG
		bool "Verbose debugging output" if EMBEDDED
		depends on INFINIBAND_MTHCA
		default y
		---help---
		  This option causes debugging code to be compiled into the
