From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [cdc_ncm] guidance and help refactoring cdc_ncm
Date: Mon, 1 Jun 2015 13:41:34 +0200 (CEST)
Message-ID: <alpine.LNX.2.20.1506011319330.4326@localhost.localdomain>
References: <alpine.LNX.2.20.1505311628420.16456@localhost.localdomain> <20150601005917.GB5320@kroah.com> <alpine.LNX.2.20.1506010818110.3158@localhost.localdomain> <1433144906.1557.2.camel@suse.com> <alpine.LNX.2.20.1506011020001.3741@localhost.localdomain>
 <1433155778.1884.12.camel@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1433155778.1884.12.camel-l3A5Bk7waGM@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thank you Oliver, thank you all for reading this thread and the attention.
For a more detailed discussion and how we got here, you might google for the 
thread:
"Is this 32-bit NCM?"
and
"Is this 32-bit NCM?y" (follow up).
Where the "y" letter comes from a mistake of mine.

The specification does only mandate the position of the NTH (header). The rest 
can be in any order and position in general. This will work with most devices: 
except, of course, those from Huawei.
Our aggregate looks something like this from my perspective (anyone correct me 
in case):
NTH: header
NDP: contains indexing informations
ethernet packet 1
ethernet packet 2
...
ethernet packet n;

While it should look like:
NTH: header
ethernet packet 1
ethernet packet 2
...
ethernet packet n;
NDP: contains indexing informations

but, when introducing such a change: you might break other devices now working. 
Infact, clearly there are multiple vendors producing NCM device, as you might 
also see by looking at the dirver's comments.
So in general, we should be able to dynamically change the way in which the 
driver order things in the package.
and that's why I initially proposed the "redesign".

thank you guys, for the patience and time.
Enrico
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
