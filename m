From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net/wireless: enable wiphy device to suspend/resume
 asynchronously
Date: Thu, 13 Aug 2015 15:13:44 +0200
Message-ID: <1439471624.2114.30.camel@sipsolutions.net>
References: <55B9B3BA.6080406@linux.intel.com>
	 <CANUX_P3PMsvWCWWciwCsRvf5PqLVEK9d9S=2Gbq+EotVGffEow@mail.gmail.com>
	 (sfid-20150730_075551_447889_FECED471)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Emmanuel Grumbach <egrumbach@gmail.com>,
	"Fu, Zhonghui" <zhonghui.fu@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANUX_P3PMsvWCWWciwCsRvf5PqLVEK9d9S=2Gbq+EotVGffEow@mail.gmail.com> (sfid-20150730_075551_447889_FECED471)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-07-30 at 08:55 +0300, Emmanuel Grumbach wrote:
> On Thu, Jul 30, 2015 at 8:18 AM, Fu, Zhonghui
> <zhonghui.fu@linux.intel.com> wrote:
> > Enable wiphy device to suspend/resume asynchronously. This can 
> > improve
> > system suspend/resume speed.
> > 
> 
> How will that impact the timing with respect to the suspend call
> coming from the bus?
> I think that a few drivers rely on the suspend call of the wiphy
> device happening before the suspend call to the bus device.
> 

Yes, we can't do this for precisely this reason unless we have a way to
somehow keep the dependency between the two - possibly by also marking
the other one as async (although I don't know if the async framework in
general has any FIFO guarantees, which would be required for this.)

I've dropped the patch.

johannes
