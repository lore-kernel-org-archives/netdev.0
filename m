From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 10/13] staging: r8188eu: Remove wrapper
 _enter_critical_mutex()
Date: Sat, 15 Feb 2014 11:23:48 -0600
Message-ID: <52FFA2A4.2010405@lwfinger.net>
References: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
 <1392418457-3203-11-git-send-email-Larry.Finger@lwfinger.net>
 <20140215104155.GC26776@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org,
 netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140215104155.GC26776@mwanda>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On 02/15/2014 04:41 AM, Dan Carpenter wrote:
> On Fri, Feb 14, 2014 at 04:54:14PM -0600, Larry Finger wrote:
>> diff --git a/drivers/staging/rtl8188eu/hal/usb_ops_linux.c b/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
>> index 1fa5370..d5f6a32 100644
>> --- a/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
>> +++ b/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
>> @@ -49,7 +49,9 @@ static int usbctrl_vendorreq(struct intf_hdl *pintfhdl, u8 request, u16 value, u
>>   		goto exit;
>>   	}
>>
>> -	_enter_critical_mutex(&dvobjpriv->usb_vendor_req_mutex, NULL);
>> +	if (mutex_lock_interruptible(&dvobjpriv->usb_vendor_req_mutex))
>> +		status = -ENOMEM;
>> +		goto exit;
>>
>
> Missing curly braces.

Thanks for seeing this. Fixing this also removes the uninitialized variable 
warnings, which should have been a clue. Perhaps my wife is right, and I am 
getting senile!

Actually a simple "return -ENOMEM" is sufficient as nothing happens at label 
exit other than "return status".

Larry
