From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH RFC] c_can_pci: generic module for c_can on PCI
Date: Mon, 11 Jun 2012 15:51:45 +0200
Message-ID: <4FD5F7F1.3010602@grandegger.com>
References: <20120604165619.15ba43bf@pyramind.ukuu.org.uk>  <4FC135C6.5030206@grandegger.com>  <1338816766-7089-1-git-send-email-federico.vaga@gmail.com>  <1338816766-7089-2-git-send-email-federico.vaga@gmail.com> <20120604164531.GA22000@mail.gnudd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, federico.vaga@gmail.com,
	mkl@pengutronix.de, giancarlo.asnaghi@st.com, alan@linux.intel.com,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alessandro Rubini <rubini@gnudd.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120604164531.GA22000@mail.gnudd.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/04/2012 06:45 PM, Alessandro Rubini wrote:
>> Anythign wrong with 
>>
>> bool aligned32;
> 
> I personally think booleans are evil.  But both this and the other
> thing:
> 
>>> +static u16 c_can_pci_read_reg_aligned_to_16bit(struct c_can_priv *priv,
>>> +						void *reg)
>>
>> I'm a bit worried this function name might be too short ;)
> 
> come from the platform driver this is based on (I already blamed
> federico offlist for not preserving authorship of the original file).
> 
> So, this file is mostly copied from the platform driver, which is a
> duplication of code.  A mandated duplication, given how the thing
> is currently laid out: the c_can core driver exports functions that
> the other two files are using (the platform and the new pci driver).
> 
> In my opinion, it would be much better to have one less layer and no
> exports at all. The core driver should be a platform driver, and the
> pci driver would just build platform data and register the platform
> device.

Do you have examples for that approach? Not sure yet if it really saves
code and makes it more readable.

> Sure this isn't up to federico, who has the pci device but cannot
> access any boards where the previous driver is used.  What do the
> maintainers think? I (or federico :) may propose a reshaping, if
> the idea makes sense.

I would suggest to provide the c_can_pci driver using the *current* API,
even if it's not optimal. Federicos patch then already looks quite good.
It should use the new register access methods introduced by the D_CAN
support patch, though.

Any further improvements to the device abstraction and a more consistent
handling of the platform data are welcome.

Wolfgang.
