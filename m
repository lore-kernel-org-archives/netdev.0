From: Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Subject: Re: QEMU PIC indirection patch for in-kernel APIC work
Date: Tue, 10 Apr 2007 15:49:11 +0300
Message-ID: <461B87C7.4010809@qumranet.com>
References: <1176087018.11664.65.camel@localhost.localdomain>
	<4619E6DC.3010804@qumranet.com>
	<1176111984.11664.90.camel@localhost.localdomain>
	<461A41CA.9080201@qumranet.com>
	<20070410080729.GB16621@2ka.mipt.ru>
	<461B48A8.1060904@qumranet.com>
	<20070410085825.GA20004@2ka.mipt.ru>
	<461B7334.8090807@qumranet.com> <20070410115035.GA2247@2ka.mipt.ru>
	<461B8069.6070007@qumranet.com>
	<20070410123034.GA11493@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20070410123034.GA11493-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=kvm-devel>
List-Post: <mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Tue, Apr 10, 2007 at 03:17:45PM +0300, Avi Kivity (avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org) wrote:
>   
>>> Check a link please in case we are talking about different ideas:
>>> http://marc.info/?l=linux-netdev&m=112262743505711&w=2
>>>
>>>  
>>>       
>> I don't really understand what you're testing there.  in particular, how 
>> can the copying time change so dramatically depending on whether you've 
>> just rebooted or not?
>>     
>  
> I tested page remapping time - i.e. time to replace a page in two
> different mappings - the same should be performed in host and guest
> kernels if such design is going to be used for communication.
>
> I can only explain after-reboot slow copy with empty caches - arbitrary
> kernel pages were copied into buffer (not the same data as in posted
> code).
>   

Doing this in kvm would be significantly more complex, as we'd need to 
use full reverse mapping to locate all guest mappings (we already 
reverse map writable pages for other reasons), so the 25-50% difference 
might be nullified or even turn into overhead.

Here are the Xen numbers for reference.  Xen probably has more overhead 
than kvm for such things, though, as it needs to do hypercalls from dom0 
which is in-kernel for kvm.

http://lists.xensource.com/archives/html/xen-devel/2007-03/msg01218.html

-- 
error compiling committee.c: too many arguments to function


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
