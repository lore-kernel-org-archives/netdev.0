From: Bjorn Andersson <bjorn-UYDU3/A3LUY@public.gmane.org>
Subject: Re: [PATCH 4/4] dt: binding: Add Qualcomm wcn36xx WiFi binding
Date: Mon, 25 Jan 2016 09:50:17 -0800
Message-ID: <CAJAp7OjVBkBQTsmg5JUcmeA+ZQO=NCATn0zRj3ipdkB2qGPuhA@mail.gmail.com>
References: <1451266467-15377-1-git-send-email-bjorn.andersson@sonymobile.com>
	<1451266467-15377-5-git-send-email-bjorn.andersson@sonymobile.com>
	<20151229183440.GC12450@rob-hp-laptop>
	<20151229190357.GJ16437@tuxbot>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	yfw <fengwei.yin-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	linux-arm-msm <linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	wcn36xx <wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151229190357.GJ16437@tuxbot>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 29, 2015 at 11:03 AM, Bjorn Andersson <bjorn-UYDU3/A3LUY@public.gmane.org> wrote:
> On Tue 29 Dec 10:34 PST 2015, Rob Herring wrote:
>
>> On Sun, Dec 27, 2015 at 05:34:27PM -0800, Bjorn Andersson wrote:
>> > Add binding representing the Qualcomm wcn3620/60/80 WiFi block.
>> > Signed-off-by: Bjorn Andersson <bjorn.andersson-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org>
>> > ---
>> >  .../bindings/net/wireless/qcom,wcn36xx-wifi.txt    | 76 ++++++++++++++++++++++
>> >  1 file changed, 76 insertions(+)
>> >  create mode 100644 Documentation/devicetree/bindings/net/wireless/qcom,wcn36xx-wifi.txt
>> >
>> > diff --git a/Documentation/devicetree/bindings/net/wireless/qcom,wcn36xx-wifi.txt b/Documentation/devicetree/bindings/net/wireless/qcom,wcn36xx-wifi.txt
>> > new file mode 100644
>> > index 000000000000..7b314b9f30af
>> > --- /dev/null
>> > +++ b/Documentation/devicetree/bindings/net/wireless/qcom,wcn36xx-wifi.txt
>> > @@ -0,0 +1,76 @@
>> > +Qualcomm WCN36xx WiFi Binding
>> > +
>> > +This binding describes the Qualcomm WCN36xx WiFi hardware. The hardware block
>> > +is part of the Qualcomm WCNSS core, a WiFi/BT/FM combo chip, found in a variety
>> > +of Qualcomm platforms.
>>
>> Are BT/FM functions completely separate? If so, separate bindings are
>> okay. If not, then we need to describe the full chip.
>>
>
> It's three different hardware blocks (WiFi, BT and FM-radio) with shared
> RF-hardware and an ARM core for control logic.
>
> There seems to be some control commands going towards the BT part that
> controls coexistence properties of the RF-hardware, but other than that
> I see it as logically separate blocks.
>
>
> So I think it's fine to model this as separate pieces in DT.
>

After more testing I've concluded that there is a timing dependency
between the WiFi driver and the wcnss_ctrl driver. If the WiFi driver
starts communicating with the WLAN subsystem in the WCNSS block before
we have finished uploading the NV data to the WCNSS core further
communication will fail.

So looks like I need to remodel this slightly to take this into account :/

Regards,
Bjorn
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
