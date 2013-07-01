From: Alex Bligh <alex@alex.org.uk>
Subject: Re: kernel panic in skb_copy_bits
Date: Mon, 01 Jul 2013 09:29:02 +0100
Message-ID: <A8CFF199DB41859580D3A04A@Ximines.local>
References: <51CBAA48.3080802@oracle.com>
 <1372311118.3301.214.camel@edumazet-glaptop> <51CD0E67.4000008@oracle.com>
 <6BFD5AF235F72F13CE646A0D@nimrod.local> <51D0F514.3070309@oracle.com>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Frank Blaschka <frank.blaschka@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	zheng.x.li@oracle.com, Xen Devel <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Jan Beulich <JBeulich@suse.com>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	Alex Bligh <alex@alex.org.uk>
To: Joe Jin <joe.jin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51D0F514.3070309@oracle.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe,

> Do you know if have a fix for above? so far we also suspected the
> grant page be unmapped earlier, we using 4.1 stable during our test.

A true fix? No, but I posted a patch set (see later email message
for a link) that you could forward port. The workaround is:

>> A workaround is to turn off O_DIRECT use by Xen as that ensures
>> the pages are copied. Xen 4.3 does this by default.
>>
>> I believe fixes for this are in 4.3 and 4.2.2 if using the
>> qemu upstream DM. Note these aren't real fixes, just a workaround
>> of a kernel bug.
>
> The guest is pvm, and disk model is xvbd, guest config file as below:
...
> I think this only for pvhvm/hvm?

I don't have much experience outside pvhvm/hvm, but I believe it
should work for any device.

Testing was simple - just find all (*) the references to O_DIRECT
in your device model and remove them!

(*)=you could be less lazy than me and find the right ones.

I am guessing it will be the same ones though.

-- 
Alex Bligh
