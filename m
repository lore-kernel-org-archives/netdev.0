From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 07/19] timberdale: mfd_cell is now implicitly available to drivers
Date: Thu, 7 Apr 2011 09:24:01 -0700
Message-ID: <BANLkTi=tZ56CEVcGQ_dQb=HmNDP6TEKxMg@mail.gmail.com>
References: <20110202195417.228e2656@queued.net> <20110202200812.3d8d6cba@queued.net>
 <20110331230522.GI437@ponder.secretlab.ca> <20110401112030.GA3447@sortiz-mobl>
 <20110401104756.2f5c6f7a@debxo> <BANLkTi=bCd_+f=EG-O=U5VH_ZNjFhxkziQ@mail.gmail.com>
 <20110401235239.GE29397@sortiz-mobl> <BANLkTi=bq=OGzXFp7qiBr7x_BnGOWf=DRQ@mail.gmail.com>
 <20110404100314.GC2751@sortiz-mobl> <20110405030428.GB29522@ponder.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andres Salomon <dilinger@queued.net>, linux-kernel@vger.kernel.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	khali@linux-fr.org, ben-linux@fluff.org,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	David Brownell <dbrownell@users.sourceforge.net>,
	linux-i2c@vger.kernel.org, linux-media@vger.kernel.org,
	netdev@vger.kernel.org, spi-devel-general@lists.sourceforge.net,
	Mocean Laboratories <info@mocean-labs.com>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110405030428.GB29522@ponder.secretlab.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 4, 2011 at 8:04 PM, Grant Likely <grant.likely@secretlab.ca=
> wrote:
> On Mon, Apr 04, 2011 at 12:03:15PM +0200, Samuel Ortiz wrote:
>> diff --git a/include/linux/platform_device.h b/include/linux/platfor=
m_device.h
>> index d96db98..734d254 100644
>> --- a/include/linux/platform_device.h
>> +++ b/include/linux/platform_device.h
>> @@ -14,6 +14,8 @@
>> =A0#include <linux/device.h>
>> =A0#include <linux/mod_devicetable.h>
>>
>> +struct mfd_cell;
>> +
>> =A0struct platform_device {
>> =A0 =A0 =A0 const char =A0 =A0 =A0* name;
>> =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 id;
>> @@ -23,6 +25,9 @@ struct platform_device {
>>
>> =A0 =A0 =A0 const struct platform_device_id *id_entry;
>>
>> + =A0 =A0 /* MFD cell pointer */
>> + =A0 =A0 struct mfd_cell *mfd_cell;
>> +
>
> Move this down to by the of_node pointer. =A0May as well collect all =
the
> supplemental data about the device in the same place.

So, okay.  wow.  I have *no* idea what I was smoking at this point in
time.  The of_node pointer is in struct device which is definitely not
the place to put the mfd_cell pointer (and you probably though I was
crazy when I suggested it).  Greg was totally right to complain about
moving it into struct device.  Sorry for causing trouble.

Move it back into struct platform_device and you should be good.  I
just talked to greg, and there should be any issues with locating it
there.

g.
