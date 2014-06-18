From: Varka Bhadram <varkabhadram-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v2 1/3] ieee802154:
 cc2520: adds driver for TI CC2520 radio
Date: Wed, 18 Jun 2014 14:56:16 +0530
Message-ID: <53A15B38.6060404@gmail.com>
References: <1403068565-32224-1-git-send-email-varkab@cdac.in>
	<1403068565-32224-2-git-send-email-varkab@cdac.in>
	<20140618091010.GB26461@leverpostej>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1871295936890116296=="
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org"
	<linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20140618091010.GB26461@leverpostej>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--===============1871295936890116296==
Content-Type: multipart/alternative;
	boundary="------------060905080901050000010303"

This is a multi-part message in MIME format.
--------------060905080901050000010303
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 06/18/2014 02:40 PM, Mark Rutland wrote:
> On Wed, Jun 18, 2014 at 06:16:03AM +0100, Varka Bhadram wrote:
>> Driver support:
>>          - Tx and Rx of IEEE-802.15.4 packets.
>>          - Energy Detection on channel.
>>          - Setting the Channel for the radio. [b/w 11 - 26 channels]
>>          - Start and Stop the radio.
>>
>> Signed-off-by: Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>
>> ---
>>   drivers/net/ieee802154/cc2520.c |  968 +++++++++++++++++++++++++++++++++++++++
>>   include/linux/spi/cc2520.h      |   26 ++
>>   2 files changed, 994 insertions(+)
>>   create mode 100644 drivers/net/ieee802154/cc2520.c
>>   create mode 100644 include/linux/spi/cc2520.h
> [...]
>
>> +static struct cc2520_platform_data *
>> +cc2520_get_platform_data(struct spi_device *spi)
>> +{
>> +       struct cc2520_platform_data *pdata;
>> +       struct device_node __maybe_unused *np = spi->dev.of_node;
>> +       struct cc2520_private *priv = spi_get_drvdata(spi);
>> +
>> +       if (!IS_ENABLED(CONFIG_OF) || !np)
>> +               return spi->dev.platform_data;
> Surely "if (!np)" is good enough?

This condition i chooses because either of thing is defined.
If the CONFIG_OF is enabled or devicetree node defined in the devicetree source.

I think checking np is enough.

> [...]
>
>> +static int cc2520_probe(struct spi_device *spi)
>> +{
>> +       struct cc2520_private *priv;
>> +       struct pinctrl *pinctrl;
>> +       struct cc2520_platform_data *pdata;
>> +       struct device_node __maybe_unused *np = spi->dev.of_node;
> This looks to be definitely unused rather than __maybe_unused. There are
> no other occuences of "np" in this function.

|This macro defined like this.
#define  __maybe_unused  __attribute__((unused))

|

> Mark.

Varka Bhadram



--------------060905080901050000010303
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <div class="moz-cite-prefix">On 06/18/2014 02:40 PM, Mark Rutland
      wrote:<br>
    </div>
    <blockquote cite="mid:20140618091010.GB26461@leverpostej"
      type="cite">
      <pre wrap="">On Wed, Jun 18, 2014 at 06:16:03AM +0100, Varka Bhadram wrote:
</pre>
      <blockquote type="cite">
        <pre wrap="">Driver support:
        - Tx and Rx of IEEE-802.15.4 packets.
        - Energy Detection on channel.
        - Setting the Channel for the radio. [b/w 11 - 26 channels]
        - Start and Stop the radio.

Signed-off-by: Varka Bhadram <a class="moz-txt-link-rfc2396E" href="mailto:varkab-If5XQcfNmg0@public.gmane.org">&lt;varkab-If5XQcfNmg0@public.gmane.org&gt;</a>
---
 drivers/net/ieee802154/cc2520.c |  968 +++++++++++++++++++++++++++++++++++++++
 include/linux/spi/cc2520.h      |   26 ++
 2 files changed, 994 insertions(+)
 create mode 100644 drivers/net/ieee802154/cc2520.c
 create mode 100644 include/linux/spi/cc2520.h
</pre>
      </blockquote>
      <pre wrap="">
[...]

</pre>
      <blockquote type="cite">
        <pre wrap="">+static struct cc2520_platform_data *
+cc2520_get_platform_data(struct spi_device *spi)
+{
+       struct cc2520_platform_data *pdata;
+       struct device_node __maybe_unused *np = spi-&gt;dev.of_node;
+       struct cc2520_private *priv = spi_get_drvdata(spi);
+
+       if (!IS_ENABLED(CONFIG_OF) || !np)
+               return spi-&gt;dev.platform_data;
</pre>
      </blockquote>
      <pre wrap="">
Surely "if (!np)" is good enough?
</pre>
    </blockquote>
    <pre>This condition i chooses because either of thing is defined.
If the CONFIG_OF is enabled or devicetree node defined in the devicetree source.

I think checking np is enough.
</pre>
    <blockquote cite="mid:20140618091010.GB26461@leverpostej"
      type="cite">
      <pre wrap="">
[...]

</pre>
      <blockquote type="cite">
        <pre wrap="">+static int cc2520_probe(struct spi_device *spi)
+{
+       struct cc2520_private *priv;
+       struct pinctrl *pinctrl;
+       struct cc2520_platform_data *pdata;
+       struct device_node __maybe_unused *np = spi-&gt;dev.of_node;
</pre>
      </blockquote>
      <pre wrap="">
This looks to be definitely unused rather than __maybe_unused. There are
no other occuences of "np" in this function.
</pre>
    </blockquote>
    <pre style="" class="lang-c prettyprint prettyprinted"><code><span class="com">This macro defined like this.
#define</span><span class="pln"> __maybe_unused  __attribute__</span><span class="pun">((</span><span class="pln">unused</span><span class="pun">))

</span></code></pre>
    <blockquote cite="mid:20140618091010.GB26461@leverpostej"
      type="cite">
      <pre wrap="">
Mark.
</pre>
    </blockquote>
    <br>
    <pre>Varka Bhadram</pre>
    <br>
  </body>
</html>

--------------060905080901050000010303--


--===============1871295936890116296==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
HPCC Systems Open Source Big Data Platform from LexisNexis Risk Solutions
Find What Matters Most in Your Big Data with HPCC Systems
Open Source. Fast. Scalable. Simple. Ideal for Dirty Data.
Leverages Graph Analysis for Fast Processing & Easy Data Exploration
http://p.sf.net/sfu/hpccsystems
--===============1871295936890116296==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linux-zigbee-devel mailing list
Linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel

--===============1871295936890116296==--
