From: Felix Radensky <felix@allot.com>
Subject: Re: e100 "Ferguson" release
Date: Sun, 10 Aug 2003 12:00:12 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F36099C.7090002@allot.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E01022292A4@orsmsx402.jf.intel.com>
 <20030805152418.GB6695@gtf.org>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="Boundary_(ID_NRV+4kR+TEKMqsKNRaPtwQ)"
Cc: "Feldman, Scott" <scott.feldman@intel.com>,
   Ben Greear <greearb@candelatech.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary_(ID_NRV+4kR+TEKMqsKNRaPtwQ)
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7BIT

Hi, Jeff, Scott

Are you planning to fix this before 2.4.22-final ?

Thanks.

Felix.

Jeff Garzik wrote:

>On Tue, Aug 05, 2003 at 08:19:25AM -0700, Feldman, Scott wrote:
>  
>
>>>I've also noticed that the number of hard_start_xmit failures 
>>>in e1000 has increased significantly in version 5.1.13-k1. In 
>>>version 5.0.43-k1 the number of failures was much smaller.
>>>      
>>>
>>Interesting.  Felix, would you undo the change[1] below in 5.1.13-k1 and
>>see what happens?  With the change below, 5.1.13 would be more
>>aggressive on Tx cleanup, so we'll be quicker waking the queue than
>>before. 
>>
>>-scott
>>
>>        for(i = 0; i < E1000_MAX_INTR; i++)
>>-               if(!e1000_clean_rx_irq(adapter) &&
>>+               if(!e1000_clean_rx_irq(adapter) &
>>                   !e1000_clean_tx_irq(adapter))
>>                        break;
>>
>>[1] Something still bothers me about this new form where we're mixing a
>>bit-wise operator with logical operands.  Should this bother me?
>>    
>>
>
>It doesn't matter to the compiler if you make it explicit:
>
>	unsigned int rx_work = e1000_clean_rx_irq();
>	unsigned int tx_work = e1000_clean_tx_irq();
>	if (!rx_work && !tx_work)
>		break;
>
>
>  
>


--Boundary_(ID_NRV+4kR+TEKMqsKNRaPtwQ)
Content-type: text/html; charset=us-ascii
Content-transfer-encoding: 7BIT

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title></title>
</head>
<body>
Hi, Jeff, Scott<br>
<br>
Are you planning to fix this before 2.4.22-final ?<br>
<br>
Thanks.<br>
<br>
Felix.<br>
<br>
Jeff Garzik wrote:<br>
<blockquote type="cite" cite="mid20030805152418.GB6695@gtf.org">
  <pre wrap="">On Tue, Aug 05, 2003 at 08:19:25AM -0700, Feldman, Scott wrote:
  </pre>
  <blockquote type="cite">
    <blockquote type="cite">
      <pre wrap="">I've also noticed that the number of hard_start_xmit failures 
in e1000 has increased significantly in version 5.1.13-k1. In 
version 5.0.43-k1 the number of failures was much smaller.
      </pre>
    </blockquote>
    <pre wrap="">Interesting.  Felix, would you undo the change[1] below in 5.1.13-k1 and
see what happens?  With the change below, 5.1.13 would be more
aggressive on Tx cleanup, so we'll be quicker waking the queue than
before. 

-scott

        for(i = 0; i &lt; E1000_MAX_INTR; i++)
-               if(!e1000_clean_rx_irq(adapter) &amp;&amp;
+               if(!e1000_clean_rx_irq(adapter) &amp;
                   !e1000_clean_tx_irq(adapter))
                        break;

[1] Something still bothers me about this new form where we're mixing a
bit-wise operator with logical operands.  Should this bother me?
    </pre>
  </blockquote>
  <pre wrap=""><!---->
It doesn't matter to the compiler if you make it explicit:

	unsigned int rx_work = e1000_clean_rx_irq();
	unsigned int tx_work = e1000_clean_tx_irq();
	if (!rx_work &amp;&amp; !tx_work)
		break;


  </pre>
</blockquote>
<br>
</body>
</html>

--Boundary_(ID_NRV+4kR+TEKMqsKNRaPtwQ)--
