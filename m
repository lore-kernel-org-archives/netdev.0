From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: Re: [PATCH linux-next] net: batman-adv: use "__packed __aligned(2)"
 for each structure instead of "__packed(2)" region
Date: Sun, 19 Jan 2014 17:51:25 +0800
Message-ID: <52DBA01D.6040000@gmail.com>
References: <52DA65F4.5070501@gmail.com> <52DA7B9E.4040202@meshcoding.com> <4915262.qEFumRrH4p@radagast> <52DB9B39.9090502@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: James Hogan <james.hogan@imgtec.com>,
	David Miller <davem@davemloft.net>, mareklindner@neomailbox.ch,
	sw@simonwunderlich.de, b.a.t.m.a.n@lists.open-mesh.org,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-metag@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Greg KH <gregkh@linuxfoundation.org>
To: Antonio Quartulli <antonio@meshcoding.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52DB9B39.9090502@meshcoding.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/19/2014 05:30 PM, Antonio Quartulli wrote:
> On 19/01/14 02:10, James Hogan wrote:
>>
>> It appears that the following gcc patch adds support for #pragma pack:
>> http://gcc.gnu.org/ml/gcc-patches/2006-10/msg01115.html
>>
>> I gave it a quick spin on metag gcc (which is unfortunately stuck on an old 
>> version) and it seems to fix my simple test case so that #pragma pack(2) 
>> becomes equivalent to __packed __aligned(2) (for sizeof and __alignof__).
>>
> 
> Then I personally think that it is better to fix metag gcc instead of
> changing the kernel.
> 
> Actually there are many different spots where "#pragma pack" is used.
> batman-adv is just the only one having compile time checks for structure
> sizes.
> 

What Antonio said sounds reasonable to me.

>>
>> However, the __packed and __aligned are linux specific macros to abstract 
>> compiler details, whereas #pragma pack appears to be a compiler-specific WIN32 
>> style equivalent to GCC's __attribute__((packed)) and 
>> __attribute__((aligned(2))) (these are what __packed and __aligned use in 
>> compiler-gcc.h).
>>
>> Therefore I believe using the Linux abstractions is still more correct here.
> 
> If you really think so, I'd suggest to grep in the kernel and catch all
> the other occurrences of "#pragma pack" and change them all (assuming
> that using __attribute__((aligned(2))) is the way to go).
> 


Thanks.
-- 
Chen Gang

Open, share and attitude like air, water and life which God blessed
