From: Frank Rowand <frank.rowand@am.sony.com>
Subject: Re: [BUG] bisected: PandaBoard smsc95xx ethernet driver error from
 USB timeout
Date: Thu, 21 Mar 2013 13:32:31 -0700
Message-ID: <514B6E5F.2040405@am.sony.com>
References: <514A7E81.9000501@am.sony.com> <CACVXFVODZNuoLYSk60YwhFhEv5SX2QkszjjoYDWBHij7zwmhdQ@mail.gmail.com> <514B6CAF.3090406@am.sony.com>
Reply-To: <frank.rowand@am.sony.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <tom.leiming@gmail.com>,
	"stern@rowland.harvard.edu" <stern@rowland.harvard.edu>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"balbi@ti.com" <balbi@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"steve.glendinning@smsc.com" <steve.glendinning@smsc.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <514B6CAF.3090406@am.sony.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/21/13 13:25, Frank Rowand wrote:
> On 03/21/13 02:00, Ming Lei wrote:

< snip >

> ----------
> There are some timeout messages that I am not positive are symptoms of
> the problem.  With these messages, the smsc95xx driver initialization is
> successful, so the ethernet device is available.  For the first bisect
> attempt, I did not treat these messages as errors.  For the second bisect
> attempt I treated these messages as errors.  A typical example of the
> timeout message is:
> 
>   [    9.537811] hub 1-1:1.0: state 7 ports 5 chg 0000 evt 0002
>   [   17.056701] usb 1-1.1: swapper/0 timed out on ep0out len=0/4
>   [   17.062652] smsc95xx 1-1.1:1.0: eth0: Failed to write register index 0x00000108
>   [   17.070343] smsc95xx 1-1.1:1.0: eth0: Failed to write ADDRL: -110
>   [   17.076751] IP-Config: Failed to open eth0

Oops, pasted the wrong example.  This is an example of a timeout, but the
driver still works, and the system boots:

  [    6.072357] smsc95xx 1-1.1:1.0: eth0: register 'smsc95xx' at usb-ehci-omap.0-1.1, smsc95xx USB 2.0 Ethernet, fa:50:73:02:79:67
  [    6.084655] hub 1-1:1.0: state 7 ports 5 chg 0000 evt 0002
  [   11.220672] usb 1-1.1: swapper/0 timed out on ep0out len=4/4
  [   18.183441] usb 1-1.1: link qh8-0001/dc8d6640 start 2 [1/0 us]
  [   19.822296] IP-Config: Complete:

> 
>   The mention of swapper is not relevent, it just happens to be the
>   current process when the time out occurs.
> 
> I have only seen these timeout messages in the boot log, so they may not
> be a very visible symptom.  They also _might_ be unrelated to the problem,
> but my gut feel is that they are related.

< snip >

-Frank
