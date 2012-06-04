From: Alessandro Rubini <rubini@gnudd.com>
Subject: Re: [PATCH RFC] c_can_pci: generic module for c_can on PCI
Date: Mon, 4 Jun 2012 18:45:31 +0200
Message-ID: <20120604164531.GA22000@mail.gnudd.com>
References: <20120604165619.15ba43bf@pyramind.ukuu.org.uk>
  <4FC135C6.5030206@grandegger.com>
  <1338816766-7089-1-git-send-email-federico.vaga@gmail.com>
  <1338816766-7089-2-git-send-email-federico.vaga@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: federico.vaga@gmail.com, wg@grandegger.com, mkl@pengutronix.de,
	giancarlo.asnaghi@st.com, alan@linux.intel.com,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120604165619.15ba43bf@pyramind.ukuu.org.uk>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Anythign wrong with 
> 
> bool aligned32;

I personally think booleans are evil.  But both this and the other
thing:

>> +static u16 c_can_pci_read_reg_aligned_to_16bit(struct c_can_priv *priv,
>> +						void *reg)
> 
> I'm a bit worried this function name might be too short ;)

come from the platform driver this is based on (I already blamed
federico offlist for not preserving authorship of the original file).

So, this file is mostly copied from the platform driver, which is a
duplication of code.  A mandated duplication, given how the thing
is currently laid out: the c_can core driver exports functions that
the other two files are using (the platform and the new pci driver).

In my opinion, it would be much better to have one less layer and no
exports at all. The core driver should be a platform driver, and the
pci driver would just build platform data and register the platform
device.

Sure this isn't up to federico, who has the pci device but cannot
access any boards where the previous driver is used.  What do the
maintainers think? I (or federico :) may propose a reshaping, if
the idea makes sense.

/alessandro, another user of the sta2x11 where c_can_pci lives
