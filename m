From: Loic Prylli <loic@myri.com>
Subject: Re: [ofa-general] Re: IPoIB forwarding
Date: Sun, 29 Apr 2007 15:40:15 -0400
Message-ID: <4634F49F.9030408@myri.com>
References: <6.1.2.0.2.20070423160212.12db6400@mail.llnl.gov>	<20070425124652.GG1624@mellanox.co.il>	<6.1.2.0.2.20070426083410.1389d9e0@mail.llnl.gov>	<20070426161409.GF15540@mellanox.co.il>	<6.1.2.0.2.20070426095112.138e9a68@mail.llnl.gov>	<20070426180618.GJ15540@mellanox.co.il>	<6.1.2.0.2.20070427115435.13ea5ec0@mail.llnl.gov>	<46325DF3.2050203@hp.com>	<6.1.2.0.2.20070427152027.13fe46d0@mail.llnl.gov>	<46327A07.1000404@hp.com>	<6.1.2.0.2.20070427153952.13fc7d08@mail.llnl.gov>	<4632894D.40705@hp.com>
	<20070428025117.a3b1200a.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bryan Lawver <lawver1@llnl.gov>,
	Linux Network Development list <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@dev.mellanox.co.il>,
	general@lists.openfabrics.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070428025117.a3b1200a.billfink@mindspring.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org



On 4/28/2007 2:51 AM, Bill Fink wrote:
> On Fri, 27 Apr 2007, Rick Jones wrote:
>
>   
>> Bryan Lawver wrote:
>>     
>>> I had so much debugging turned on that it was not the "slowing of the 
>>> traffic" but the "non-coelescencing" that was the remedy.  The NIC is a 
>>> MyriCom NIC and these are easy options to set.
>>>       
>> As chance would have it, I've played with some Myricom myri10ge NICs recently, 
>> and even disabled large receive offload during some netperf tests :)  It is a 
>> modprobe option.  Going back now to the driver source and the README I see :-)
>>
>>
>> [..]
>>
>> rick jones
>>     
>
> What version of the myri10ge driver is this?  With the 1.2.0 version
> that comes with the 2.6.20.7 kernel, there is no myri10ge_lro module
> parameter.
>
>   


The myri10ge_lro parameter does not exists in the kernel tree. The 
option and corresponding lro code is available only in the externally 
distributed version of myri10ge. That code was submitted to the netdev 
list, but wasn't taken in the kernel tree because of the reasonable 
concern the driver might not be the right place for that code (if nobody 
else proposes something equivalent in the meantime, we might at some 
point resubmit it as a driver-independant addon, but it might not be 
that soon for manpower reasons).

Only the 1.2.0 version of the external driver makes LRO incompatible 
with forwarding. The problem should be fixed in version 1.3.0 released a 
few weeks ago (forwarding with myri10ge_lro enabled should then work), 
let us know otherwise.

Anyway, following David Miller remark about netfilter, for the next 
version we might ask the user to explicitely enable LRO rather than 
making the default.

Sorry for the inconvenience.


Loic
