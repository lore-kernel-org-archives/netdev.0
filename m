From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: Re: how about the following to elminate pci_find_device() in fore200e?
Date: Mon, 25 Oct 2004 09:31:22 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410251331.i9PDVMb0017733@ginger.cmf.nrl.navy.mil>
References: <20041025125648.GA32619@infradead.org>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-reply-to: Your message of "Mon, 25 Oct 2004 13:56:48 BST."
             <20041025125648.GA32619@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20041025125648.GA32619@infradead.org>,Christoph Hellwig writes:
>> -static struct fore200e* fore200e_boards = NULL;
>> +LIST_HEAD(fore200e_boards);
>
>should still be static (yes, static LIST_HEAD(foo); is okay)

missed that.  didnt mean to undo the static.

>indentation looks messed but, but I assume you did this to match the
>rest of the file?

yeah.  however, i will probably fix the tabbing on anything that is
rewritten wholesale.  switching tabbing in the middle of a routine
is a bit hard to read though.

>> +#ifdef CONFIG_ATM_FORE200E_PCA
>> +    if (!pci_module_init(&fore200e_pca_driver))
>> +	return 0;
>> +#endif
>> +
>> +    if (!list_empty(&fore200e_boards))
>> +	return 0;
>
>the driver only supports either sbus or pci at the same time?

i believe it supports pci, sbus or both at the same time (and hopefully
still does).  fore200e_boards is only used to track non-pci boards now.
if pci_module_init() succeeds we have to stay resident--non-pci boards
have been found and inited by this point.  if pci_module_init() fails,
we need to check to see if any other boards were found before exiting.
