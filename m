From: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 19:53:57 +0200
Message-ID: <4804EBB5.7000100@hartkopp.net>
References: <20080414213238.GB28833@kroah.com> <48042F7F.8030608@hartkopp.net> <20080415161158.GE9704@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>,
	ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080415161158.GE9704-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Greg KH wrote:
> On Tue, Apr 15, 2008 at 06:30:55AM +0200, Oliver Hartkopp wrote:
>   
>> Just some obvious things to reduce the source code hopping for the
>> review and to reduce the source code size.
>>
>> Regards,
>> Oliver
>>
>>     
>>> +
>>> +#define DRIVER_VERSION			"1.2"
>>> +#define MOD_AUTHOR			"Option Wireless"
>>> +#define MOD_DESCRIPTION			"USB High Speed Option driver"
>>> +#define MOD_LICENSE			"GPL"
>>> +
>>>   
>>>       
>> Please move the MODULE_OWNER(), MODULE_LICENSE(), etc. macros from the
>> end of this file directly to this point.
>>     
>
> Does that really matter?
>
>   

Not for the compiler :)

But when you are able to put things together that helps to understand 
the code much better (at least for me). I'm not a wizard so when it 
helps me to find code belonging together it probably helps other people 
also.


>>> +/*****************************************************************************/
>>> +/* Prototypes                                                                */
>>> +/*****************************************************************************/
>>>   
>>>       
>> This is a real forward declaration hell. Please try to reorder the
>> functions in the code to make this as obsolte as possible.
>>     
>
> I've already stripped down a lot of them, will work on the remaining
> ones, I wanted to get the code out for review first.
>
>   

Ok.

>>> +/*****************************************************************************/
>>> +/* Helping functions                                                         */
>>> +/*****************************************************************************/
>>> +
>>> +/* convert a character representing a hex value to a number */
>>> +static unsigned char hex2dec(unsigned char digit)
>>> +{
>>> +
>>> +	if ((digit >= '0') && (digit <= '9'))
>>> +		return (digit - '0');
>>> +	/* Map all characters to 0-15 */
>>> +	if ((digit >= 'a') && (digit <= 'z'))
>>> +		return (digit - 'a' + 10) % 16;
>>> +	if ((digit >= 'A') && (digit <= 'Z'))
>>> +		return (digit - 'A' + 10) % 16;
>>> +	return 16;
>>> +}
>>> +
>>>   
>>>       
>> Shouldn't this already be somewhere else in the kernel?
>>     
>
> Do you know where?
>
>   

Hm - i found one by grep after 'hex2' in drivers/net/cxgb3/t3_hw.c :

static unsigned int hex2int(unsigned char c)
{
return isdigit(c) ? c - '0' : toupper(c) - 'A' + 10;
}

But nothing in lib/* ...


>>> +
>>> +/* module parameters */
>>> +static int debug;
>>> +static int procfs = 1;
>>> +static int tty_major;
>>> +static int disable_net;
>>> +static int enable_autopm;
>>> +
>>>   
>>>       
>> please move the module_param() stuff and MODULE_PARM_DESC() from the end
>> of the file right to this place.
>>     
>
> Does it really matter?
>
>   

Same as stated above. If you would put the MODULE_PARM_DESC() right here 
the formerly defined variables are documented in one go without any /* 
comments */ and you just know the meaning for the rest of the review.

>>> +static int hso_proc_port_info(char *buf, char **start, off_t offset, int count,
>>> +			      int *eof, void *data)
>>> +{
>>> +	int len = 0;
>>> +	struct hso_device *hso_dev = (struct hso_device *)data;
>>> +	char *port_name = NULL;
>>> +
>>> +	D1("count: %d", count);
>>>   
>>>       
>> This debug macro looks like it is from the very beginning of the
>> implementation. Remove it.
>>     
>
> Why?
>   

Why not? If it is not really needed it should be omitted.

In general i'm a friend of debug-code, but when i touches the mainline 
kernel IMO one should reconsider if all the debug code remains necessary.

>   
>>> +
>>> +static int hso_serial_read_proc(char *page, char **start, off_t off, int count,
>>> +				int *eof, void *data)
>>> +{
>>> +	return 0;
>>> +}
>>> +
>>>   
>>>       
>> ???
>>     
>
> Already been pointed out that they can be removed.
>   

Sorry. Didn't catch that.


Regards,
Oliver


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
