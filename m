From: Alexey ORISHKO <alexey.orishko@stericsson.com>
Subject: Re: CDC NCM missing Zero Length Packets
Date: Tue, 26 Apr 2011 17:59:25 +0200
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520153E2A4AAFD2@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matthias Benesch <twoofseven@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:50948 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751493Ab1DZP7a convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 11:59:30 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 22, 2011 at 4:32 PM, Matthias Benesch <twoofseven@freenet.de> wrote:
> Hello,
>
> I am testing the USB-CDC NCM host driver. One issue that was found by one
> USB device stack provider, is that the current implementation is not sending
> ZLP or short packets if the dwNtbOutMaxSize reported by the device is
> greater than CDC_NCM_NTB_MAX_SIZE_TX (=16383 bytes).
>

I'd like to point out, that NCM is not a Mass Storage and increasing max
buffer size in the device will lead to reduced throughput at the end. By 
increasing max buffer size, you are also increasing overall latency, which
will hit hard streaming and other services.

NCM specification was written with approach that device is less capable than
the host. The issue you mentioned, is not addressed properly in the specification,
but might be fixed in the next version of NCM spec.

16K buffer size in the current driver was chosen as a result of testing and
as a tradeoff between latency and throughput and should be suitable for LTE
speeds. Devices using 21 Mbit HSPA radio could function happily with 8K buffers.

By using bigger buffer in the device your USB device stack provider forces
host driver constantly send short packets, which will significantly reduce
benefits provided by DMA controller. While having maximum data traffic your
device interrupt load would be twice as high as the load when device buffer
size is equal or less than host driver buffer size.

As a conclusion: 
- yes, current driver version has a bug (no short packet sent) and I will
submit a patch for it after testing. 
- Patch provided a few days ago is not a proper solution and can be considered as
a workaround only.
- I also suggest you to talk to your usb device stack vendor, because your product
might work much better if issues mentioned above are taking into consideration.

Regards,
Alexey

