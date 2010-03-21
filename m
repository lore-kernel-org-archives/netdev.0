From: Avi Kivity <avi@redhat.com>
Subject: Re: Unable to create more than 1 guest virtio-net device using	vhost-net
 backend
Date: Sun, 21 Mar 2010 13:58:29 +0200
Message-ID: <4BA609E5.40504@redhat.com>
References: <1269037167.5127.12.camel@w-sridhar.beaverton.ibm.com> <20100321095544.GA6443@redhat.com> <4BA5F0D5.6020801@redhat.com> <20100321101527.GH6443@redhat.com> <4BA5F50B.8080302@redhat.com> <20100321113443.GB12339@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <samudrala.sridhar@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>, gleb@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100321113443.GB12339@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/21/2010 01:34 PM, Michael S. Tsirkin wrote:
> On Sun, Mar 21, 2010 at 12:29:31PM +0200, Avi Kivity wrote:
>    
>> On 03/21/2010 12:15 PM, Michael S. Tsirkin wrote:
>>      
>>>>> Nothing easy that I can see. Each device needs 2 of these.  Avi, Gleb,
>>>>> any objections to increasing the limit to say 16?  That would give us
>>>>> 5 more devices to the limit of 6 per guest.
>>>>>
>>>>>
>>>>>            
>>>> Increase it to 200, then.
>>>>
>>>>          
>>> OK. I think we'll also need a smarter allocator
>>> than bus->dev_count++ than we now have. Right?
>>>
>>>        
>> No, why?
>>      
> We'll run into problems if devices are created/removed in random order,
> won't we?
>    

unregister_dev() takes care of it.

>> Eventually we'll want faster scanning than the linear search we employ
>> now, though.
>>      
> Yes I suspect with 200 entries we will :). Let's just make it 16 for
> now?
>    

Let's make it 200 and fix the performance problems later.  Making it 16 
is just asking for trouble.

-- 
error compiling committee.c: too many arguments to function

